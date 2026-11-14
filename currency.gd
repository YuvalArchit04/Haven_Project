extends Area2D

signal collected(amount)

@export var value: int = 10
var initial_y: float = 0.0
var time_passed: float = 0.0
var is_collected: bool = false

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	initial_y = position.y
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if is_collected:
		return
	time_passed += delta * 3.0
	position.y = initial_y + sin(time_passed) * 4.0

func _on_body_entered(body: Node2D) -> void:
	if is_collected:
		return
	if body.is_in_group("player") or body.name == "Player":
		is_collected = true
		collected.emit(value)
		
		# Feedback tween
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(sprite, "scale", sprite.scale * 1.5, 0.2)
		tween.tween_property(sprite, "modulate:a", 0.0, 0.2)
		tween.chain().tween_callback(queue_free)
