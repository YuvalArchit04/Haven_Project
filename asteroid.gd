extends CharacterBody2D

@export var debris_index: int = 0  # 0 for random, 1, 2, or 3
@export var speed: float = 120.0
@export var move_axis: Vector2 = Vector2.UP  # Fixed axis: Vector2.UP (vertical) or Vector2.RIGHT (horizontal)
@export var rotation_speed: float = 0.8
@export var is_lethal: bool = true

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var debris_textures = [
	preload("res://assets/Debris-1.png"),
	preload("res://assets/Debris-2.png"),
	preload("res://assets/Debris-3.png")
]

func _ready() -> void:
	if debris_index > 0 and debris_index <= debris_textures.size():
		sprite.texture = debris_textures[debris_index - 1]
	else:
		var chosen = randi() % debris_textures.size()
		sprite.texture = debris_textures[chosen]
		
	if move_axis == Vector2.ZERO:
		move_axis = Vector2.UP
	move_axis = move_axis.normalized()
	velocity = move_axis * speed

func _physics_process(delta: float) -> void:
	sprite.rotation += rotation_speed * delta
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		# Reverse along fixed axis on collision
		move_axis = -move_axis
		velocity = move_axis * speed
		
		var collider = collision.get_collider()
		if is_lethal and collider and (collider.is_in_group("player") or collider.name == "Player"):
			_kill_player(collider)

func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_lethal and (body.is_in_group("player") or body.name == "Player"):
		_kill_player(body)

func _kill_player(player_node: Node2D) -> void:
	if player_node.has_method("die"):
		player_node.die()
	elif player_node.get_parent() and player_node.get_parent().has_method("respawn_player"):
		player_node.get_parent().respawn_player()
