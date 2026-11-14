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

func _ready() -> void:
	# Start background music
	var am = get_node_or_null("/root/AudioManager")
	if am and am.has_method("play_music"):
		am.play_music()

	if tutorial_panel:
		tutorial_panel.visible = false
	if mode_panel:
		mode_panel.visible = false
	
	if play_button:
		play_button.pressed.connect(_on_play_pressed)
		_setup_button_retro(play_button)
	if tutorial_button:
		tutorial_button.pressed.connect(_on_tutorial_pressed)
		_setup_button_retro(tutorial_button)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)
		_setup_button_retro(quit_button)
	if close_tutorial_btn:
		close_tutorial_btn.pressed.connect(_on_close_tutorial_pressed)
		_setup_button_retro(close_tutorial_btn)
		
	if easy_mode_btn:
		easy_mode_btn.pressed.connect(_on_easy_mode_selected)
		_setup_button_retro(easy_mode_btn)
	if hard_mode_btn:
		hard_mode_btn.pressed.connect(_on_hard_mode_selected)
		_setup_button_retro(hard_mode_btn)
	if close_mode_btn:
		close_mode_btn.pressed.connect(_on_close_mode_pressed)
		_setup_button_retro(close_mode_btn)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if mode_panel and mode_panel.visible:
			_on_close_mode_pressed()
		elif tutorial_panel and tutorial_panel.visible:
			_on_close_tutorial_pressed()
		else:
			_on_quit_pressed()

func _setup_button_retro(btn: Button) -> void:
	btn.mouse_entered.connect(func():
		var am = get_node_or_null("/root/AudioManager")
		if am and am.has_method("play_tick"):
			am.play_tick()
	)

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

func _play_click_sfx() -> void:
	var am = get_node_or_null("/root/AudioManager")
	if am and am.has_method("play_tick"):
		am.play_tick()
