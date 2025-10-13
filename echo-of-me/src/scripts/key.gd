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
		#emit_signal("picked_up_key")
		#queue_free()
		has_been_picked_up = true
		hide()
		monitoring = false            # stop detecting overlaps
		#col.disabled = true           # disable collisions
		print("key picked up!")

func _on_reset_level() -> void:
	global_position = start_position
	#var new_object = key_scene.instantiate()
	#add_child(new_object)
	#new_object.global_position = position 
	has_been_picked_up = false
	show()
	monitoring = true
	#col.disabled = false
	
