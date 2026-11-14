extends Area2D

signal reached_goal

var is_reached: bool = false
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if sprite:
		sprite.rotation += 0.5 * delta

func _on_body_entered(body: Node2D) -> void:
	if is_reached:
		return
	if body.is_in_group("player") or body.name == "Player":
		is_reached = true
		reached_goal.emit()
