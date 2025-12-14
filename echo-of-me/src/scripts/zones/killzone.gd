extends Area2D

@onready var level_controller := get_tree().current_scene.get_node("LevelController")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		# Kill the player - death screen will handle the reset
		if body is CharacterBase:
			body.die()
		# Old death_text system is now replaced by death_screen
