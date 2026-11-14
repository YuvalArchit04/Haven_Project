extends CharacterBody2D

@export var player: CharacterBody2D
@export var throw_speed: float = 480.0
@export var ball_friction: float = 120.0
@export var recall_speed: float = 520.0
@export var dash_multiplier: float = 0.95
@export var catch_radius: float = 44.0
enum State { READY, AIMING, THROWN, RECALLING }
var current_state: State = State.READY

var is_aiming: bool = false
var aim_dir: Vector2 = Vector2.RIGHT
var throw_timer: float = 0.0

func _ready():
	visible = false
	var col = get_node_or_null("CollisionPolygon2D")
	if col:
		col.disabled = true
	if player:
		add_collision_exception_with(player)

func _unhandled_input(event: InputEvent) -> void:
	if current_state == State.READY or current_state == State.AIMING:
		if event.is_action_pressed("throw"):
			current_state = State.AIMING
			is_aiming = true
			queue_redraw()
		elif event.is_action_released("throw") and is_aiming:
			is_aiming = false
			queue_redraw()
			_shoot()

func _draw() -> void:
	if (current_state == State.AIMING or is_aiming) and player:
		var mouse_pos = get_global_mouse_position()
		var dir = player.global_position.direction_to(mouse_pos)
		if dir == Vector2.ZERO:
			dir = Vector2.RIGHT
		
		var line_len: float = 180.0
		var dot_spacing: float = 12.0
		var dot_radius: float = 3.0
		var count = int(line_len / dot_spacing)
		var origin = to_local(player.global_position)
		for i in range(1, count + 1):
			var pt = origin + dir * (i * dot_spacing)
			draw_circle(pt, dot_radius + 1.0, Color(0.05, 0.05, 0.08, 0.9))
			draw_circle(pt, dot_radius, Color(0.3, 0.95, 1.0, 0.95))

func _shoot() -> void:
	if not player:
		return
	var mouse_pos = get_global_mouse_position()
	var dir = player.global_position.direction_to(mouse_pos)
	if dir == Vector2.ZERO:
		dir = Vector2.RIGHT
		
	if player.has_method("freeze"):
		player.freeze(0.2)
	else:
		player.velocity = Vector2.ZERO
	
	global_position = player.global_position + dir * 40.0
	visible = true
	var col = get_node_or_null("CollisionPolygon2D")
	if col:
		col.disabled = false
	
	velocity = dir * throw_speed
	throw_timer = 0.35
	current_state = State.THROWN
	
	var am = get_node_or_null("/root/AudioManager")
	if am and am.has_method("play_throw"):
		am.play_throw()

func _physics_process(delta):
	if throw_timer > 0.0:
		throw_timer -= delta

	match current_state:
		State.READY:
			if player:
				global_position = player.global_position
		State.AIMING:
			if player:
				global_position = player.global_position
			queue_redraw()
		State.THROWN:
			velocity = velocity.move_toward(Vector2.ZERO, ball_friction * delta)
			var collision = move_and_collide(velocity * delta)
			if collision:
				velocity = velocity.bounce(collision.get_normal())
			if Input.is_action_just_pressed("recall"):
				current_state = State.RECALLING
				var am = get_node_or_null("/root/AudioManager")
				if am and am.has_method("play_recall"):
					am.play_recall()
		State.RECALLING:
			if not player:
				return
			var dist = global_position.distance_to(player.global_position)
			var dir = global_position.direction_to(player.global_position)
			
			velocity = dir * recall_speed
			var step_move = velocity * delta
			
			if throw_timer <= 0.0 and (dist <= catch_radius or dist <= step_move.length() + 8.0):
				var impact_dir = dir if dir != Vector2.ZERO else Vector2.DOWN
				var target_player = player
				
				velocity = Vector2.ZERO
				visible = false
				var col = get_node_or_null("CollisionPolygon2D")
				if col:
					col.disabled = true
				current_state = State.READY
				
				if target_player:
					target_player.velocity = Vector2.ZERO
					var timer = get_tree().create_timer(0.2)
					timer.timeout.connect(func():
						if target_player:
							target_player.velocity = impact_dir * recall_speed * dash_multiplier
							var game = target_player.get_parent()
							if game and game.has_method("add_trauma"):
								game.add_trauma(0.45)
					)
			else:
				var collision = move_and_collide(step_move)
				if collision:
					velocity = velocity.bounce(collision.get_normal())
