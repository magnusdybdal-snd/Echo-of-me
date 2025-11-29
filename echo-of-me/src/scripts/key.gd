extends Area2D


var start_position : Vector2
var key_scene = preload("res://src/scenes/key.tscn")


# Tracks if key has been picked up.
@export var has_been_picked_up = false

func _ready() -> void:
	start_position = global_position
	var level_controller = get_tree().current_scene.get_node("LevelController")
	level_controller.connect("reset_level", Callable(self, "_on_reset_level"))

# Player enters area.
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		has_been_picked_up = true
		AudioPlayer.play_sfx("key_pickup", -12.0)
		hide()
		monitoring = false            # stop detecting overlaps

func _on_reset_level() -> void:
	global_position = start_position
	has_been_picked_up = false
	show()
	monitoring = true
	
