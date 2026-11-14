extends CharacterBody2D

@export var friction: float = 1500.0

func _physics_process(delta: float) -> void:
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	move_and_slide()
	
