extends Area2D

@onready var level_controller := get_tree().current_scene.get_node("LevelController")
@onready var death_text: Label = $"../CanvasLayer/death_text"

func _ready() -> void:
	death_text.hide()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and is_instance_valid(level_controller):
		AudioPlayer.play_sfx("die")
			
		death_text.show()
		await get_tree().create_timer(1.0).timeout
		death_text.hide()
		level_controller.hard_reset()
