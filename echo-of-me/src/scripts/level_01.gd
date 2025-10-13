extends Node2D

@onready var door: StaticBody2D = $LevelController/Door
@onready var key: Area2D = $Levelcontroller/Key
@onready var collision_shape_door: CollisionShape2D = $Trigger/CollisionShapeDoor
@onready var trigger: Area2D = $Trigger

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Override default door animation (closed)
	door.DoorSprite.play("open")
	door.lightrays.show()
	# Flags to ensure no need for key scene.
	door.opened = true
	door.need_key = false
	# Ensure player is able to walk through door.
	door.collision_area_shape_top.set_deferred("disabled", true) # Safely get rid of collision boxes
	door.collision_area_shape_bottom.set_deferred("disabled", true)
	
	# Level controller for resetting of level.
	var level_controller = get_tree().current_scene.get_node("LevelController")
	level_controller.connect("reset_level", Callable(self, "_on_reset_level"))


func _on_reset_level() -> void:
	# Override default door animation (closed)
	door.DoorSprite.play("open")
	door.lightrays.show()
	# Flags to ensure no need for key scene.
	door.opened = true
	door.need_key = false
	# Ensure player is able to walk through door.
	door.collision_area_shape_top.set_deferred("disabled", true)
	door.collision_area_shape_bottom.set_deferred("disabled", true)
