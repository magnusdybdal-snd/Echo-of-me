extends StaticBody2D

# Collision shapes that block player passage when door is locked
@onready var collision_area_shape_top: CollisionShape2D = $CollisionAreaShape_top
@onready var collision_area_shape_bottom: CollisionShape2D = $CollisionAreaShape_bottom
@onready var collision_shape_door: CollisionShape2D = $LevelController/Door/CollisionShapeDoor

# Reference to key in level (null if no key exists)
@onready var key: Area2D = $"../Key" if has_node("../Key") else null
# Visual elements for door state
@onready var DoorSprite: AnimatedSprite2D = $Trigger/AnimatedSprite2D
@onready var lightrays: AnimatedSprite2D = $Lightrays

# Door state flags
var opened: bool = false
@export var need_key: bool = true

func _ready() -> void:
	# Validate that key exists if door requires one
	if need_key and key == null:
		push_error("Door requires key, but Key node not found in level")
		need_key = false

	# Connect to level reset system
	var level_controller = get_tree().current_scene.get_node("LevelController")
	if level_controller:
		level_controller.connect("reset_level", Callable(self, "_on_reset_level"))
	else:
		push_error("Door: Levelcontroller not found in scene")

	# Initialize door to locked/unlocked based on configuration
	set_door_to_initial_state()
	
# Resets door to initial locked/unlocked state
func _on_reset_level():
	set_door_to_initial_state()

# Helper function to set door to its starting state
func set_door_to_initial_state():
	if need_key:
		lock_door()
	else:
		unlock_door()

# Unlocks door if player has collected the key (when key is required)
func _on_trigger_body_entered(body: Node2D) -> void:
	# Ignore if not player or door already open
	if not body.is_in_group("player") or opened:
		return
	# Unlock if key requirement is met
	if need_key and key.has_been_picked_up:
		unlock_door()
		
# Locks the door, preventing player passage
func lock_door() -> void:
	DoorSprite.play("closed")
	lightrays.hide()
	opened = false
	collision_area_shape_top.set_deferred("disabled", false) # Enable collision (blocks player)
	collision_area_shape_bottom.set_deferred("disabled", false)

# Unlocks the door, allowing player passage
func unlock_door() -> void:
	DoorSprite.play("open")
	lightrays.show()
	opened = true
	collision_area_shape_top.set_deferred("disabled", true) # Disable collision (allows passage)
	collision_area_shape_bottom.set_deferred("disabled", true)
