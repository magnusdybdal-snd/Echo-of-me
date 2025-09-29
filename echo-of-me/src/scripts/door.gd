extends StaticBody2D
@onready var DoorSprite: AnimatedSprite2D = $Trigger/AnimatedSprite2D
@onready var collision_area_shape_top: CollisionShape2D = $CollisionAreaShape_top
@onready var collision_area_shape_bottom: CollisionShape2D = $CollisionAreaShape_bottom
@onready var collision_shape_door: CollisionShape2D = $Door/CollisionShapeDoor

@onready var lightrays: AnimatedSprite2D = $Lightrays

@onready var key: Area2D = $"../Key"
var has_key: bool = false
var opened: bool = false

func _ready() -> void:
	DoorSprite.play("closed")
	key.picked_up_key.connect(_on_key_picked_up)
	#lightrays.play("empty")
	lightrays.hide()

# Key has been picked up
func _on_key_picked_up():
	has_key = true
	print("keypickedupfromDOOR")

# Key pickup bool is detected.
func open():
	if opened:
		return
	opened = true
	DoorSprite.play("open")
	# Defer physics-state changes:
	collision_area_shape_top.set_deferred("disabled", true) # Safely get rid of collision boxes
	collision_area_shape_bottom.set_deferred("disabled", true)
	print("should have been dissabled now")

func _on_trigger_body_entered(body: Node2D) -> void:
	if has_key and body.is_in_group("player"):
		print("You have the key -> door can open!")
		lightrays.show()
		lightrays.play("default")
		# Defer calling open so we don't change physics in the same step:
		call_deferred("open")
