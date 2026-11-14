extends Area2D

const GameState = preload("res://game_state.gd")

signal activated(checkpoint_pos: Vector2)

var is_active: bool = false
@onready var sprite: Sprite2D = $Sprite2D
@onready var label: Label = $Label

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if not GameState.easy_mode:
		modulate = Color(0.4, 0.4, 0.5, 0.5)
		if label:
			label.text = "[OFFLINE - HARDCORE]"

func _process(delta: float) -> void:
	if sprite:
		sprite.rotation += 1.0 * delta

func _on_body_entered(body: Node2D) -> void:
	if is_active:
		return
	if not GameState.easy_mode:
		return
	if body.is_in_group("player") or body.name == "Player":
		is_active = true
		activated.emit(global_position)
		
		var am = get_node_or_null("/root/AudioManager")
		if am and am.has_method("play_tick"):
			am.play_tick()
			
		if sprite:
			var tween = create_tween()
			tween.tween_property(sprite, "modulate", Color(0.3, 1.0, 0.5, 1.0), 0.2)
			tween.parallel().tween_property(sprite, "scale", sprite.scale * 1.3, 0.15)
			tween.tween_property(sprite, "scale", sprite.scale, 0.15)
		if label:
			label.text = "✓ CHECKPOINT ACTIVE"
			label.add_theme_color_override("font_color", Color(0.3, 1.0, 0.5, 1.0))
