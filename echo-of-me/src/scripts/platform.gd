extends AnimatableBody2D

var start_position : Vector2

func _ready():
	start_position = global_position
	var level_controller = get_tree().current_scene.get_node("LevelController")
	level_controller.connect("reset_level", Callable(self, "_on_reset_level"))
	
func _on_reset_level():
	global_position = start_position
	$Rise.stop()


func rise():
	$Rise.play("rise")


func _on_button_pressed() -> void:
	rise()
