extends Node2D

@onready var level_controller: Node = $LevelController

var rigid_box_scene = preload("res://src/scenes/rigid_box.tscn")
var previous_echo_count: int = 0
var spawn_position: Vector2 = Vector2(164, 248) # Default spawn position, adjust as needed
var spawned_boxes: Array = []  # Track all spawned boxes


func _ready() -> void:
	previous_echo_count = 0
	# Connect to reset signal to destroy boxes when level resets
	level_controller.connect("reset_level", Callable(self, "_on_reset_level"))


func _on_reset_level() -> void:
	# Destroy all spawned boxes
	for box in spawned_boxes:
		if is_instance_valid(box):
			box.queue_free()
	spawned_boxes.clear()
	previous_echo_count = 0


func _process(_delta: float) -> void:
	# Check if a new echo has been spawned
	var current_echo_count = level_controller.echoes.size()

	if current_echo_count > previous_echo_count:
		# New echo(s) spawned, spawn boxes for each one
		var boxes_to_spawn = current_echo_count - previous_echo_count
		spawn_boxes_with_delay(boxes_to_spawn)
		previous_echo_count = current_echo_count


func spawn_boxes_with_delay(count: int) -> void:
	for i in range(count):
		await get_tree().create_timer(2.0).timeout
		spawn_rigid_box()


func spawn_rigid_box() -> void:
	var box = rigid_box_scene.instantiate()
	box.global_position = spawn_position
	level_controller.add_child(box)
	spawned_boxes.append(box)  # Track the spawned box
