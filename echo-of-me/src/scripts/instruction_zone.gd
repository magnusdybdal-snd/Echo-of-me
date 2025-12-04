extends Area2D

## Shows labels when player is inside the area, hides when outside

# Labels to show / hide
@export var labels: Array[NodePath] = []

@onready var level_controller = get_tree().current_scene.get_node_or_null("LevelController")

func _ready() -> void:
	# Set collision mask to detect player
	collision_layer = 0
	collision_mask = 1

func _process(_delta: float) -> void:
	# Check if echoes exist, we dont display instructions if player spawned echo
	var echo_spawned = false
	if level_controller:
		echo_spawned = level_controller.get("echoes").size() > 0

	# Check if player is inside the area
	var player_inside = _is_player_inside()

	# Show labels if player is inside area and has not spawned an echo
	for label_path in labels:
		var label = get_node(label_path)
		if label:
			label.visible = player_inside and not echo_spawned

func _is_player_inside() -> bool:
	var overlapping_bodies = get_overlapping_bodies()
	for body in overlapping_bodies:
		if body.is_in_group("player"):
			return true
	return false
