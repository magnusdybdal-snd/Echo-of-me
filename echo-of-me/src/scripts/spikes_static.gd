extends Area2D

@onready var level_controller := get_tree().current_scene.get_node("LevelController")

func _ready() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and is_instance_valid(level_controller):		
		await get_tree().create_timer(1.0).timeout
		level_controller.hard_reset()
		
