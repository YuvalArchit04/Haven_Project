extends Area2D

signal player_hit

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") or body.name == "Player":
		player_hit.emit()
		if body.has_method("die"):
			body.die()
		elif body.get_parent() and body.get_parent().has_method("respawn_player"):
			body.get_parent().respawn_player()
