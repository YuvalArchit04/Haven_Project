extends CharacterBody2D

@export var player: CharacterBody2D
@export var throw_speed: float = 900.0
@export var ball_friction: float = 1200.0
@export var base_accel: float = 800.0
@export var pull_strength: float = 4.0
@export var dash_multiplier: float = 0.85
@export var catch_radius: float = 30.0
enum State { READY, THROWN, RECALLING }
var current_state: State = State.READY

func _ready():
	visible = false
	$CollisionPolygon2D.disabled = true
