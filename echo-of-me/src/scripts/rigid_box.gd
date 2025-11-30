extends RigidBody2D

const THROW_FORCE := 400
const CARRY_OFFSET := Vector2(0, -40) # Position above player's head

@onready var box_collision_shape = $CollisionShape2D

var start_position : Vector2
var beeing_pushed := false
var beeing_carried := false
var carrier : CharacterBase = null # Who is carrying the box

# Physics reset flag for resetting the box. processed in _integrate_forces
var queue_reset:= false

# Drag sound player (persistent for looping)
var drag_player: AudioStreamPlayer

# Impact detection
var last_collision_time := 0.0
const IMPACT_COOLDOWN := 0.3  # Minimum time between impact sounds

func _ready():
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	start_position = global_position

	if physics_material_override == null:
		physics_material_override = PhysicsMaterial.new()

	physics_material_override.friction = 1.0
	physics_material_override.bounce = 0.0

	# Enable contact monitoring for collision detection
	contact_monitor = true
	max_contacts_reported = 4

	var level_controller = get_tree().current_scene.get_node_or_null("LevelController")
	if level_controller != null:
		level_controller.connect("reset_level", Callable(self, "_on_reset_level"))
	else:
		print("Warning: LevelController not found - box reset won't work")

	# Create drag sound player
	drag_player = AudioStreamPlayer.new()
	drag_player.bus = "reverb"
	add_child(drag_player)

	# Connect to body_entered signal for impact detection
	body_entered.connect(_on_body_entered_impact)
		
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	if queue_reset:
		queue_reset = false
		# Reset velocity and position directly in physics state
		state.linear_velocity = Vector2.ZERO
		state.angular_velocity = 0.0
		state.transform.origin = start_position
		
		print("BOX RESET via _integrate_forces - Position: ", global_position)

func _physics_process(_delta: float) -> void:
	# Adjust friction based on state
	print("freeze_mode: " + str(freeze_mode))
	print("beeing_carried: " + str(beeing_carried))
	print("freeze: " + str(freeze))
	print("sleeping: " + str(sleeping))
	print("linear_velocity: " + str(linear_velocity))
	print("gravity_scale: " + str(gravity_scale))
	if beeing_pushed:
		physics_material_override.friction = 0.0
	else:
		physics_material_override.friction = 1.0

	# If box is carried, follow the carrier
	if beeing_carried and is_instance_valid(carrier):
		freeze = true
		global_position = carrier.global_position + CARRY_OFFSET
		stop_drag_sound()  # Stop drag sound when carried
	else:
		freeze = false

	# Play drag sound when being pushed and moving
	if beeing_pushed and abs(linear_velocity.x) > 10.0:  # Threshold to avoid sound when barely moving
		play_drag_sound()
	else:
		stop_drag_sound()
		
func pick_up(by_character: CharacterBase):
	if beeing_carried:
		return

	beeing_carried = true
	carrier = by_character
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	stop_drag_sound()  # Stop drag sound when picked up

	# Disable collision with carrier
	add_collision_exception_with(carrier)
	
func place_down(direction: float):
	if not beeing_carried:
		return

	print("PLACE_DOWN called - freeze_mode before: ", freeze_mode)
	beeing_carried = false
	freeze = false
	linear_velocity = Vector2.ZERO
	global_position.x += (direction * 30.0)
	global_position.y -= CARRY_OFFSET.y

	# Reenable collision with carrier when placing box down
	if is_instance_valid(carrier):
		remove_collision_exception_with(carrier)

	carrier = null
	stop_drag_sound()  # Stop drag sound when placed down
	print("PLACE_DOWN done - freeze_mode after: ", freeze_mode)
	
# Throw the box
func throw_box(direction: float, velocity: Vector2):
	if not beeing_carried:
		return

	beeing_carried = false
	freeze = false

	# Apply throw force
	linear_velocity = velocity
	linear_velocity.x = direction * THROW_FORCE

	# Enable collision with carrier
	if is_instance_valid(carrier):
		remove_collision_exception_with(carrier)

	carrier = null
	stop_drag_sound()  # Stop drag sound when thrown
		
# Check if box can be pixked up
func can_be_picked_up(character: CharacterBase) -> bool:
	if beeing_carried:
		return false

	# Check distance to box (increased range for echo consistency)
	var distance = global_position.distance_to(character.global_position)
	return distance < 60.0
		
			
# Handles reseting of position when level is reset with E or R
func _on_reset_level():
	print("====== BOX RESET CALLED ======")
	print("  Before - beeing_carried: ", beeing_carried)
	print("  Before - freeze: ", freeze)
	print("  Before - freeze_mode: ", freeze_mode)

	# We wait one frame to let any player/echo move away before messing with the box
	await get_tree().physics_frame

	# Clear all collision exceptions
	var exceptions = get_collision_exceptions()
	print("  Clearing ", exceptions.size(), " collision exceptions")
	for exception in exceptions:
		remove_collision_exception_with(exception)

	# Reset ALL state flags before any physics operations
	beeing_carried = false
	beeing_pushed = false
	carrier = null  # Clear carrier reference BEFORE physics operations
	freeze = false
	stop_drag_sound()  # Stop drag sound when resetting

	# Queue the physics reset to happen in _integrate_forces
	sleeping = false
	queue_reset = true

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("add_nearby_box"):
		body.add_nearby_box(self)
		beeing_pushed = true
		linear_damp = 0.0

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.has_method("remove_nearby_box"):
		body.remove_nearby_box(self)
		beeing_pushed = false
		linear_velocity.x = 0.0

# Plays drag sound (looping)
func play_drag_sound():
	if drag_player != null and not drag_player.playing:
		if "box_drag" in AudioPlayer.sfx_collections:
			var sounds = AudioPlayer.sfx_collections["box_drag"]
			if sounds.size() > 0:
				drag_player.stream = sounds[0]
				drag_player.play()

# Stops drag sound
func stop_drag_sound():
	if drag_player != null and drag_player.playing:
		drag_player.stop()

# Detects impacts with world/objects
func _on_body_entered_impact(_body: Node):
	# Ignore impacts when being carried or pushed (only play on throw/fall impacts)
	if beeing_carried or beeing_pushed:
		return

	# Check cooldown to avoid spam
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_collision_time < IMPACT_COOLDOWN:
		return

	# Play impact sound
	AudioPlayer.play_sfx("box_impact", -10.0)
	last_collision_time = current_time
