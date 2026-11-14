extends Control

const GameState = preload("res://game_state.gd")

@onready var play_button: Button = %PlayButton
@onready var tutorial_button: Button = %tutorial
@onready var quit_button: Button = %quit
@onready var tutorial_panel: PanelContainer = %TutorialPanel
@onready var close_tutorial_btn: Button = %CloseTutorialButton

@onready var mode_panel: PanelContainer = %ModePanel
@onready var easy_mode_btn: Button = %EasyModeButton
@onready var hard_mode_btn: Button = %HardModeButton
@onready var close_mode_btn: Button = %CloseModeButton
@onready var speed_slider: HSlider = get_node_or_null("%SpeedSlider")
@onready var speed_label: Label = get_node_or_null("%SpeedLabel")

@onready var skins_button: Button = get_node_or_null("%SkinsButton")
@onready var skins_panel: PanelContainer = get_node_or_null("%SkinsPanel")
@onready var gems_label: Label = get_node_or_null("%GemsLabel")
@onready var skins_list: VBoxContainer = get_node_or_null("%SkinsList")
@onready var close_skins_btn: Button = get_node_or_null("%CloseSkinsButton")

func _ready() -> void:
	var am = get_node_or_null("/root/AudioManager")
	if am and am.has_method("play_music"):
		am.play_music()

	if tutorial_panel:
		tutorial_panel.visible = false
	if mode_panel:
		mode_panel.visible = false
	if skins_panel:
		skins_panel.visible = false
	
	if speed_slider:
		speed_slider.value = GameState.ball_speed_multiplier
		speed_slider.value_changed.connect(_on_speed_slider_changed)
		_update_speed_label(speed_slider.value)
	
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
	if tutorial_button:
		tutorial_button.pressed.connect(_on_tutorial_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
	if close_tutorial_btn:
		close_tutorial_btn.pressed.connect(_on_close_tutorial_pressed)
	if skins_button:
		skins_button.pressed.connect(_on_skins_pressed)
	if close_skins_btn:
		close_skins_btn.pressed.connect(_on_close_skins_pressed)
		
	if easy_mode_btn:
		easy_mode_btn.pressed.connect(_on_easy_mode_selected)
	if hard_mode_btn:
		hard_mode_btn.pressed.connect(_on_hard_mode_selected)
	if close_mode_btn:
		close_mode_btn.pressed.connect(_on_close_mode_pressed)

func _on_speed_slider_changed(val: float) -> void:
	GameState.ball_speed_multiplier = val
	_update_speed_label(val)

func _update_speed_label(val: float) -> void:
	if speed_label:
		speed_label.text = "BALL SPEED: %d%%" % int(val * 100.0)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if mode_panel and mode_panel.visible:
			_on_close_mode_pressed()
		elif tutorial_panel and tutorial_panel.visible:
			_on_close_tutorial_pressed()
		elif skins_panel and skins_panel.visible:
			_on_close_skins_pressed()
		else:
			_on_quit_pressed()

func _on_play_pressed() -> void:
	_play_click_sfx()
	if mode_panel:
		mode_panel.visible = true
		if easy_mode_btn:
			easy_mode_btn.grab_focus()
	else:
		get_tree().change_scene_to_file("res://game.tscn")

func _on_easy_mode_selected() -> void:
	_play_click_sfx()
	GameState.easy_mode = true
	get_tree().change_scene_to_file("res://game.tscn")

func _on_hard_mode_selected() -> void:
	_play_click_sfx()
	GameState.easy_mode = false
	get_tree().change_scene_to_file("res://game.tscn")

func _on_close_mode_pressed() -> void:
	_play_click_sfx()
	if mode_panel:
		mode_panel.visible = false
		if play_button:
			play_button.grab_focus()

func _on_tutorial_pressed() -> void:
	_play_click_sfx()
	if tutorial_panel:
		tutorial_panel.visible = true
		if close_tutorial_btn:
			close_tutorial_btn.grab_focus()

func _on_close_tutorial_pressed() -> void:
	_play_click_sfx()
	if tutorial_panel:
		tutorial_panel.visible = false
		if tutorial_button:
			tutorial_button.grab_focus()

func _on_quit_pressed() -> void:
	_play_click_sfx()
	get_tree().quit()

func _on_skins_pressed() -> void:
	_play_click_sfx()
	if skins_panel:
		skins_panel.visible = true
		_refresh_skins_ui()
		if close_skins_btn:
			close_skins_btn.grab_focus()

func _on_close_skins_pressed() -> void:
	_play_click_sfx()
	if skins_panel:
		skins_panel.visible = false
		if skins_button:
			skins_button.grab_focus()

func _refresh_skins_ui() -> void:
	if gems_label:
		gems_label.text = "💎 Gems: %d" % GameState.total_gems
	if not skins_list:
		return
	
	for child in skins_list.get_children():
		child.queue_free()
	
	for skin_name in GameState.SKINS.keys():
		var info = GameState.SKINS[skin_name]
		var cost = info["cost"]
		var is_unlocked = skin_name in GameState.unlocked_skins
		var is_equipped = (skin_name == GameState.current_skin)
		
		var row = HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 36)
		
		var name_lbl = Label.new()
		name_lbl.text = skin_name
		name_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_lbl.add_theme_color_override("font_color", info["color"])
		name_lbl.add_theme_font_size_override("font_size", 12)
		row.add_child(name_lbl)
		
		var action_btn = Button.new()
		action_btn.custom_minimum_size = Vector2(140, 32)
		action_btn.add_theme_font_size_override("font_size", 11)
		
		if is_equipped:
			action_btn.text = "EQUIPPED"
			action_btn.disabled = true
		elif is_unlocked:
			action_btn.text = "EQUIP"
			action_btn.pressed.connect(func():
				_play_click_sfx()
				GameState.current_skin = skin_name
				_refresh_skins_ui()
			)
		else:
			action_btn.text = "BUY (%d 💎)" % cost
			action_btn.disabled = (GameState.total_gems < cost)
			action_btn.pressed.connect(func():
				if GameState.total_gems >= cost:
					_play_click_sfx()
					GameState.total_gems -= cost
					GameState.unlocked_skins.append(skin_name)
					GameState.current_skin = skin_name
					_refresh_skins_ui()
			)
		row.add_child(action_btn)
		skins_list.add_child(row)

func _play_click_sfx() -> void:
	var am = get_node_or_null("/root/AudioManager")
	if am and am.has_method("play_tick"):
		am.play_tick()
