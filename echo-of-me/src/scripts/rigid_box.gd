extends RigidBody2D

const THROW_FORCE := 400
const CARRY_OFFSET := Vector2(0, -40) # Position above player's head

var start_position : Vector2
var beeing_pushed := false
var beeing_carried := false
var carrier : CharacterBase = null # Who is carrying the box

func _ready():
	start_position = global_position
	
	if physics_material_override == null:
		physics_material_override = PhysicsMaterial.new()
		
	physics_material_override.friction = 1.0
	physics_material_override.bounce = 0.0
	
	var level_controller = get_tree().current_scene.get_node_or_null("LevelController")
	if level_controller != null:
		level_controller.connect("reset_level", Callable(self, "_on_reset_level"))
	else:
		print("Warning: LevelController not found - box reset won't work")

func _physics_process(_delta: float) -> void:
	# Adjust friction based on state
	#print("Start position: ", start_position, " Current position: ", global_position)
	if beeing_pushed:
		physics_material_override.friction = 0.0
	else:
		physics_material_override.friction = 1.0
		
	# If box is carried, follow the carrier
	if beeing_carried and is_instance_valid(carrier):
		#freeze = true # disable physics while carried
		freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
		freeze = true
		print("!!! BOX CARRIED by ", carrier.name, " beeing_carried=", beeing_carried, " moving to: ", carrier.global_position + CARRY_OFFSET)
		global_position = carrier.global_position + CARRY_OFFSET
	elif beeing_carried:
		print("!!! ERROR: beeing_carried TRUE but carrier INVALID")
	else:
		freeze = false
		
func pick_up(by_character: CharacterBase):
	if beeing_carried:
		return
	
	beeing_carried = true
	carrier = by_character
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	
	# Disable collision with carrier
	add_collision_exception_with(carrier)
	
func place_down(direction: float):
	if not beeing_carried:
		return
		
	beeing_carried = false
	freeze = false
	linear_velocity = Vector2.ZERO
	global_position.x += (direction * 30.0)
	global_position.y -= CARRY_OFFSET.y
	
	# Reenable collision with carrier when placing box down
	if is_instance_valid(carrier):
		remove_collision_exception_with(carrier)
		
	carrier = null
	print("placed box")
	
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
	print("throw box")
		
# Check if box can be pixked up
func can_be_picked_up(character: CharacterBase) -> bool:
	if beeing_carried:
		return false

	# Check distance to box (increased range for echo consistency)
	var distance = global_position.distance_to(character.global_position)
	return distance < 60.0
		
			
# Handles reseting of position when level is reset with E or R
func _on_reset_level():
	print("BOX RESET - Start position: ", start_position, " Current position: ", global_position)

	if is_instance_valid(carrier):
		remove_collision_exception_with(carrier)

	# Reset state flags first
	beeing_carried = false
	beeing_pushed = false
	carrier = null

	# Freeze the body
	freeze_mode = RigidBody2D.FREEZE_MODE_STATIC
	freeze = true

	# Clear velocities BEFORE unfreezing using physics server
	PhysicsServer2D.body_set_state(
		get_rid(),
		PhysicsServer2D.BODY_STATE_LINEAR_VELOCITY,
		Vector2.ZERO
	)
	PhysicsServer2D.body_set_state(
		get_rid(),
		PhysicsServer2D.BODY_STATE_ANGULAR_VELOCITY,
		0.0
	)

	# Set position using physics server
	PhysicsServer2D.body_set_state(
		get_rid(),
		PhysicsServer2D.BODY_STATE_TRANSFORM,
		Transform2D.IDENTITY.translated(start_position)
	)

	# Now safe to unfreeze - velocities are already zero
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	global_position = start_position
	freeze = false

	print("BOX RESET COMPLETE - Position: ", global_position, " Carried: ", beeing_carried)

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
