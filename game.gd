extends Node2D

const GameState = preload("res://game_state.gd")

@onready var player: CharacterBody2D = $Player
@onready var ball: CharacterBody2D = $Ball
@onready var respawn_point: Marker2D = $SpawnPoint
@onready var hud_energy: Label = %EnergyLabel
@onready var hud_deaths: Label = %DeathsLabel
@onready var hud_mode: Label = %ModeLabel
@onready var victory_panel: PanelContainer = %VictoryPanel
@onready var death_flash: ColorRect = %DeathFlash
@onready var checkpoint_popup: Label = %CheckpointPopup
@onready var intro_banner: Label = %IntroBanner
@onready var play_again_btn: Button = %PlayAgainButton
@onready var next_btn: Button = get_node_or_null("%NextButton")
@onready var menu_btn: Button = %MenuButton
@onready var prize_btn: Button = get_node_or_null("%PrizeButton")
@onready var video_modal: PanelContainer = get_node_or_null("%VideoModal")
@onready var prize_video: VideoStreamPlayer = get_node_or_null("%PrizeVideoPlayer")
@onready var close_video_btn: Button = get_node_or_null("%CloseVideoBtn")

@export var next_scene_path: String = "res://game_level_2.tscn"

var energy_collected: int = 0
var death_count: int = 0
var is_level_ended: bool = false
var default_spawn_pos: Vector2 = Vector2(140, 950)
var current_checkpoint_pos: Vector2 = Vector2(140, 950)

var trauma: float = 0.0
var trauma_power: float = 2.0
var max_offset: Vector2 = Vector2(16.0, 16.0)

func _ready() -> void:
	# Ensure music is playing
	var am = get_node_or_null("/root/AudioManager")
	if am and am.has_method("play_music"):
		am.play_music()

	if respawn_point:
		default_spawn_pos = respawn_point.global_position
	current_checkpoint_pos = default_spawn_pos
	
	# Wire up player and ball
	if player and ball:
		ball.player = player
		if not player.is_in_group("player"):
			player.add_to_group("player")
			
		# Cinematic FOV Overview intro
		_setup_cinematic_intro()
	
	# Connect checkpoints
	for cp in get_tree().get_nodes_in_group("checkpoints"):
		if cp.has_signal("activated"):
			cp.activated.connect(_on_checkpoint_activated)
	
	# Connect spikes
	for spike in get_tree().get_nodes_in_group("spikes"):
		if spike.has_signal("player_hit"):
			spike.player_hit.connect(respawn_player)
	
	# Connect collectibles
	for item in get_tree().get_nodes_in_group("collectibles"):
		if item.has_signal("collected"):
			item.collected.connect(_on_currency_collected)
	
	# Connect physical push button
	var btn = get_node_or_null("PhysicalButton")
	if btn and btn.has_signal("button_activated"):
		btn.button_activated.connect(_on_button_activated)
		
	# UI buttons
	if play_again_btn:
		play_again_btn.pressed.connect(_on_play_again_pressed)
	if next_btn:
		if next_scene_path != "":
			next_btn.pressed.connect(func(): get_tree().change_scene_to_file(next_scene_path))
		else:
			next_btn.visible = false
	if menu_btn:
		menu_btn.pressed.connect(_on_menu_pressed)
	if prize_btn and video_modal and prize_video:
		prize_btn.pressed.connect(_on_prize_pressed)
	if close_video_btn and video_modal:
		close_video_btn.pressed.connect(_on_close_video_pressed)
		
	if victory_panel:
		victory_panel.visible = false
	if video_modal:
		video_modal.visible = false
	if death_flash:
		death_flash.modulate.a = 0.0
	if checkpoint_popup:
		checkpoint_popup.modulate.a = 0.0

	_update_hud()

func _process(delta: float) -> void:
	# Reset player position ONLY if they touch the bottom-most ground
	if player and not is_level_ended:
		if player.global_position.y >= 995.0:
			respawn_player()

	# Screen shake decay
	if trauma > 0.0:
		trauma = max(0.0, trauma - delta * 1.5)
		var cam: Camera2D = player.get_node_or_null("Camera2D") if player else null
		if cam:
			var amount = pow(trauma, trauma_power)
			cam.offset = Vector2(
				randf_range(-1.0, 1.0) * max_offset.x * amount,
				randf_range(-1.0, 1.0) * max_offset.y * amount
			)

func _setup_cinematic_intro() -> void:
	var cam: Camera2D = player.get_node_or_null("Camera2D")
	if not cam:
		return
		
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = 1920
	cam.limit_bottom = 1080
	
	# Start with full map overview
	cam.position_smoothing_enabled = false
	cam.global_position = Vector2(960, 540)
	cam.zoom = Vector2(1.0, 1.0)
	
	if intro_banner:
		intro_banner.visible = true
		intro_banner.modulate.a = 1.0
	
	# Smoothly zoom into Verity
	var intro_timer = get_tree().create_timer(1.2)
	intro_timer.timeout.connect(func():
		var tween = create_tween().set_parallel(true)
		tween.tween_property(cam, "global_position", player.global_position, 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(cam, "zoom", Vector2(1.7, 1.7), 0.8).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		if intro_banner:
			tween.tween_property(intro_banner, "modulate:a", 0.0, 0.4)
		tween.chain().tween_callback(func():
			cam.position_smoothing_enabled = true
			cam.position_smoothing_speed = 7.0
			cam.position = Vector2.ZERO
		)
	)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_tree().change_scene_to_file("res://main_menu.tscn")
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_R:
			respawn_player()
	elif event.is_action_pressed("throw"):
		var am = get_node_or_null("/root/AudioManager")
		if am and am.has_method("play_throw"):
			am.play_throw()
	elif event.is_action_pressed("recall"):
		var am = get_node_or_null("/root/AudioManager")
		if am and am.has_method("play_recall"):
			am.play_recall()

func _on_checkpoint_activated(cp_pos: Vector2) -> void:
	if GameState.easy_mode:
		current_checkpoint_pos = cp_pos
		_show_checkpoint_banner()

func _show_checkpoint_banner() -> void:
	if checkpoint_popup:
		checkpoint_popup.modulate.a = 1.0
		var tween = create_tween()
		tween.tween_interval(1.5)
		tween.tween_property(checkpoint_popup, "modulate:a", 0.0, 0.4)

func respawn_player() -> void:
	if is_level_ended:
		return
		
	death_count += 1
	_update_hud()
	trauma = 0.6
	
	# Audio death
	var am = get_node_or_null("/root/AudioManager")
	if am and am.has_method("play_death"):
		am.play_death()
	
	# Visual death flash
	if death_flash:
		death_flash.modulate.a = 0.85
		var flash_tween = create_tween()
		flash_tween.tween_property(death_flash, "modulate:a", 0.0, 0.35)
	
	# Determine respawn position based on mode
	var target_pos = default_spawn_pos
	if GameState.easy_mode:
		target_pos = current_checkpoint_pos
	
	# Reset player position & momentum
	if player:
		player.global_position = target_pos
		player.velocity = Vector2.ZERO
		
	# Reset ball
	if ball:
		ball.global_position = target_pos
		ball.velocity = Vector2.ZERO
		if "current_state" in ball:
			ball.current_state = 0 # State.READY
		ball.visible = false
		var col = ball.get_node_or_null("CollisionPolygon2D")
		if col:
			col.disabled = true

func _on_currency_collected(amount: int) -> void:
	energy_collected += amount
	_update_hud()
	var am = get_node_or_null("/root/AudioManager")
	if am and am.has_method("play_tick"):
		am.play_tick()

func _update_hud() -> void:
	if hud_energy:
		hud_energy.text = "⚡ Energy: %d" % energy_collected
	if hud_deaths:
		hud_deaths.text = "💀 Deaths: %d" % death_count
	if hud_mode:
		if GameState.easy_mode:
			hud_mode.text = "🟢 RECON RUN (CHECKPOINTS)"
			hud_mode.add_theme_color_override("font_color", Color(0.4, 1.0, 0.6))
		else:
			hud_mode.text = "💀 IRON RUN (NO CHECKPOINTS)"
			hud_mode.add_theme_color_override("font_color", Color(1.0, 0.4, 0.4))

func _on_button_activated() -> void:
	if is_level_ended:
		return
	is_level_ended = true
	trauma = 0.4
	
	if victory_panel:
		victory_panel.visible = true
		victory_panel.modulate.a = 0.0
		var tween = create_tween()
		tween.tween_property(victory_panel, "modulate:a", 1.0, 0.3)
		if play_again_btn:
			play_again_btn.grab_focus()

func _on_play_again_pressed() -> void:
	get_tree().reload_current_scene()

func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _on_prize_pressed() -> void:
	if video_modal and prize_video:
		video_modal.visible = true
		prize_video.play()

func _on_close_video_pressed() -> void:
	if video_modal and prize_video:
		prize_video.stop()
		video_modal.visible = false
