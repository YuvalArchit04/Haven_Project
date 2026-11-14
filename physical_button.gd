extends Area2D

signal button_activated

var is_pressed: bool = false
@onready var cap_sprite: Sprite2D = $CapSprite
@onready var base_sprite: Sprite2D = $BaseSprite
@onready var label: Label = $Label

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if is_pressed:
		return
	if body.is_in_group("player") or body.name == "Player" or body.name == "Ball":
		press_button()

func press_button() -> void:
	if is_pressed:
		return
	is_pressed = true
	
	# Mechanical depression animation
	if cap_sprite:
		var tween = create_tween()
		tween.tween_property(cap_sprite, "position:y", 6.0, 0.08).set_trans(Tween.TRANS_QUAD)
		tween.parallel().tween_property(cap_sprite, "modulate", Color(0.3, 1.0, 0.5), 0.1)
	
	# Sound feedback
	var am = get_node_or_null("/root/AudioManager")
	if am and am.has_method("play_tick"):
		am.play_tick()
	else:
		# Fallback local player
		var sfx = AudioStreamPlayer.new()
		sfx.stream = preload("res://assets/Tickity Timety.mp3")
		add_child(sfx)
		sfx.play()
		sfx.finished.connect(sfx.queue_free)
		
	if label:
		label.text = "✓ EXTRACTION UNLOCKED"
		label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5))
	
	button_activated.emit()
