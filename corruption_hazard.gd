extends Area2D

signal player_killed(player)

@export_range(1, 5) var corruption_stage: int = 1
@export var move_distance: float = 0.0
@export var move_speed: float = 60.0
@export var move_direction: Vector2 = Vector2.UP

var start_pos: Vector2
var travel_time: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D

const STAGE_TEXTURES = {
	1: preload("res://assets/Corruption-1.png"),
	2: preload("res://assets/Corruption-2.png"),
	3: preload("res://assets/Corruption-3.png"),
	4: preload("res://assets/Corruption-4.png"),
	5: preload("res://assets/Corruption-5.png")
}

func _ready() -> void:
	start_pos = global_position
	body_entered.connect(_on_body_entered)
	if sprite:
		if corruption_stage in STAGE_TEXTURES:
			sprite.texture = STAGE_TEXTURES[corruption_stage]

func _physics_process(delta: float) -> void:
	if move_distance > 0.0:
		travel_time += delta * (move_speed / move_distance) * PI
		var offset = sin(travel_time) * move_distance
		global_position = start_pos + move_direction.normalized() * offset

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		player_killed.emit(body)
		if body.has_method("die"):
			body.die()
		elif body.get_parent() and body.get_parent().has_method("respawn_player"):
			body.get_parent().respawn_player()
