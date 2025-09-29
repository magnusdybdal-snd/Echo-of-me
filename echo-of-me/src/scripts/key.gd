extends Area2D

# Tracks is key has been picked up.

signal picked_up_key

# Player enters area.
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		emit_signal("picked_up_key")
		queue_free()
		print("key picked up!")
