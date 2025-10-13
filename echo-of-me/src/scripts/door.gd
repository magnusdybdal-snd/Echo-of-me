extends StaticBody2D
@onready var DoorSprite: AnimatedSprite2D = $Trigger/AnimatedSprite2D
@onready var collision_area_shape_top: CollisionShape2D = $CollisionAreaShape_top
@onready var collision_area_shape_bottom: CollisionShape2D = $CollisionAreaShape_bottom
@onready var collision_shape_door: CollisionShape2D = $LevelController/Door/CollisionShapeDoor

@onready var lightrays: AnimatedSprite2D = $Lightrays
@onready var key: Area2D = $"../Key"

var opened: bool = false

func _ready() -> void:
	DoorSprite.play("closed")
	lightrays.hide()
	var level_controller = get_tree().current_scene.get_node("LevelController")
	level_controller.connect("reset_level", Callable(self, "_on_reset_level")) # level controller signal calls reset function
	
# Resets all values/states to default
func _on_reset_level() -> void:
	DoorSprite.play("closed")
	lightrays.hide()
	opened = false
	collision_area_shape_top.set_deferred("disabled", false) # Enable collision shapes
	collision_area_shape_bottom.set_deferred("disabled", false)

# Key pickup bool is detected.
func open():
	if opened:
		return
	opened = true
	DoorSprite.play("open")
	# Defer physics-state changes:
	collision_area_shape_top.set_deferred("disabled", true) # Safely get rid of collision boxes
	collision_area_shape_bottom.set_deferred("disabled", true)

func _on_trigger_body_entered(body: Node2D) -> void:
	if key.has_been_picked_up and body.is_in_group("player"):
		print("KEY: Key aquired -> door opening!")
		lightrays.show()
		lightrays.play("default")
		call_deferred("open") # Defer calling open so we don't change physics in the same step
	else: # TODO remove debug print
		print("KEY: No key -> not opening")
