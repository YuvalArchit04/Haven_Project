extends CharacterBody2D

@export var friction: float = 450.0

var freeze_timer: float = 0.0

func freeze(duration: float = 0.15) -> void:
	velocity = Vector2.ZERO
	freeze_timer = duration

func _physics_process(delta: float) -> void:
	if freeze_timer > 0.0:
		freeze_timer -= delta
		velocity = Vector2.ZERO
		return
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	move_and_slide()
