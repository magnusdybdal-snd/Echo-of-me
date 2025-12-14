class_name CharacterBase
extends CharacterBody2D

# Constants for player movement and forces
const ACCELERATION := 1300.0
const FRICTION := 2000.0
const AIR_RESISTANCE := 400
const BOX_PUSH_SPEED := 300.0
const SPEED := 150.0

# Wall climb constants
const WALL_SLIDE_GRAVITY := 55.0 # How fast you will slide down the wall
const WALL_JUMP_FORCE := 200 # Push force off the wall when jumping
const WALL_JUMP_GRACE_TIME := 0.2 # Grace period after leaaving wall (seconds)

# Used to control animations
#var is_sprinting := false
var is_dead := false
var anim_lock := false
var is_dashing := false
var has_used_dash := false

var is_echo := false

# Cached powerup states
var can_sprint := false
var can_double_jump := false
var can_wall_climb := false
var used_double_jump := false
var can_dash := false
var target_speed := 0.0

# Wall jump coyote time
var wall_jump_timer := 0.0
var last_wall_normal := Vector2.ZERO

# Dash timer
var dash_timer := 0.0

# Tracks boxes to pick up or apply push force to
var nearby_boxes: Array = []
var pick_up_target: RigidBody2D = null
var carried_box: RigidBody2D = null

var facing_direction := 1.0 # -1.0 left, 1.0 right

@onready var animated_sprite = %AnimatedSprite2D

# Audio is now managed by AudioPlayer singleton
# (Old audio nodes in player.tscn can be removed)

# Footstep audio player (persistent for looping)
var footstep_player: AudioStreamPlayer
var current_footstep_sound: String = ""

# Push sound player (persistent for looping)
var push_player: AudioStreamPlayer

## The current state the player is in
var state: BasePlayerState = PlayerStates.IDLE

func _ready() -> void:
	
	state.enter(self)
	# Create footstep audio player
	footstep_player = AudioStreamPlayer.new()
	footstep_player.bus = "reverb"
	add_child(footstep_player)

	# Create push sound player
	push_player = AudioStreamPlayer.new()
	push_player.bus = "reverb"
	push_player.volume_db = -10.0
	add_child(push_player)

## Change the current player state and rund the correct functinos
func change_state_to(new_state: BasePlayerState) -> void:
	state.exit(self)
	state = new_state
	state.enter(self)

func _physics_process(delta):
	state.pre_update(self)
	state.update(self, delta)
	
	
	if is_dead:
		return 
	if "in_cutscene" in self and self.in_cutscene:
		move_and_slide()  # Still allow AnimationPlayer to move the character
		return

	check_powerups()
	update_wall_jump_timer(delta)
	update_dash_timer(delta)
	apply_movement(delta)
	update_animation(get_direction())
	push_boxes()
	move_and_slide()
	
func check_powerups() -> void:
	can_sprint = GameManager.has_powerup("sprint")
	can_double_jump = GameManager.has_powerup("double_jump") and carried_box == null
	can_wall_climb = GameManager.has_powerup("wall_climb") and carried_box == null
	can_dash = GameManager.has_powerup("dash") and carried_box == null

# Updates wall jump grace timer
func update_wall_jump_timer(delta: float) -> void:
	if is_on_wall_only() and can_wall_climb:
		# Resets the timer if we are on the wall
		wall_jump_timer = WALL_JUMP_GRACE_TIME
		# Get the normal of the wall we are colliding with
		var wall_col := get_slide_collision(0) if get_slide_collision_count() > 0 else null
		if wall_col:
			last_wall_normal = wall_col.get_normal()
	# Just left the wall, start counting down the grace timer
	elif wall_jump_timer > 0:
		wall_jump_timer -= delta

# Updates dash timer and resets dash flags
func update_dash_timer(delta: float) -> void:
	# Reset dash availability when touching ground
	if is_on_floor():
		has_used_dash = false

	# Count down dash duration
	if dash_timer > 0:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
	
# Check if player can wall jump -> Is on wall OR within wall jump grace period
func can_wall_jump() -> bool:
	return can_wall_climb and (is_on_wall_only() or wall_jump_timer > 0) and !carried_box
	

# Acceleration based movement system
func apply_movement(delta: float) -> void:
	var direction = get_direction()
	var is_pushing := is_pushing_box(direction) if direction != 0 else false

	# Handle push sound
	if is_pushing:
		play_push_sound()
	else:
		stop_push_sound()

	# Override target speed if pushing, or ensure minimum air control
	var final_speed: float
	if is_pushing:
		final_speed = BOX_PUSH_SPEED
	elif not is_on_floor() and target_speed < SPEED:
		# Ensure minimum air control speed even when jumping from idle
		final_speed = SPEED
	else:
		final_speed = target_speed

	# Determine acceleration rate
	var accel_rate: float
	if direction != 0:
		accel_rate = ACCELERATION
	else:
		accel_rate = FRICTION if is_on_floor() else AIR_RESISTANCE

	# Apply movement with direction
	velocity.x = move_toward(velocity.x, final_speed * direction, accel_rate * delta)

# Check if we're actively pushing a box in the given direction	
func is_pushing_box(direction: float) -> bool:
	if nearby_boxes.is_empty():
		return false
		
	for box in nearby_boxes:
		if not is_instance_valid(box):
			continue
			
		# Check if box is in the direction we are moving
		var to_box = box.global_position.x - global_position.x
		if sign(to_box) == sign(direction):
			return true
			
	return false

func update_animation(direction: float) -> void:

	# Flips sprite based on the direction the character is facing
	if direction > 0:
		animated_sprite.flip_h = false
		facing_direction = 1.0
	elif direction < 0:
		animated_sprite.flip_h = true
		facing_direction = -1.0

# Sets flags for animation control and plays jump animation

				
func push_boxes() -> void:
	var direction = get_direction()
	
	# Only push if player is moving
	if direction == 0 or nearby_boxes.is_empty():
		return
		
	for box in nearby_boxes:
		if not is_instance_valid(box):
			nearby_boxes.erase(box)
			continue
			
		# Calculate the direction of push based on player position
		var push_direction = (box.global_position - global_position).normalized()
		
		# Only push if we are moving towards the box
		if sign(push_direction.x) == sign(direction):
			if box.has_method("set_target_velocity"):
				box.set_target_velocity(velocity.x)
			else:
				box.linear_velocity.x = velocity.x
				
func handle_box_interraction():
	pass
						
# Function that finds the nearest box to the player
func find_nearest_box() -> RigidBody2D:
	var boxes = get_tree().get_nodes_in_group("boxes")
	var nearest: RigidBody2D = null
	var nearest_dist = 999999.0
	
	for box in boxes:
		if box is RigidBody2D and box.has_method("can_be_picked_up"):
			if box.can_be_picked_up(self):
				var dist = global_position.distance_to(box.global_position)
				if dist < nearest_dist:
					nearest_dist = dist
					nearest = box
					
	return nearest
						
func add_nearby_box(box: RigidBody2D) -> void:
	if box not in nearby_boxes:
		nearby_boxes.append(box)
		
func remove_nearby_box(box: RigidBody2D) -> void:
	nearby_boxes.erase(box)

# Abstract method overridden by children
func get_direction() -> float:
	return 0.0
	
func die() -> void:
	if is_dead:
		return # player is already dead

	print("DIE() called - carried_box: ", carried_box)
	if carried_box != null:
		await get_tree().physics_frame
		print("  Calling place_down on box before dying")
		carried_box.freeze = false
		carried_box.place_down(facing_direction)
		carried_box = null

	is_dead = true
	velocity = Vector2.ZERO
	stop_footsteps()  # Stop footsteps when dead
	stop_push_sound()  # Stop push sound when dead
	AudioPlayer.play_sfx("die")

	# Play death animation if you have one
	if animated_sprite.sprite_frames.has_animation("death"):
		animated_sprite.play("death")

	else:
		animated_sprite.stop()

func revive() -> void:
	is_dead = false
	velocity = Vector2.ZERO

	# Resume animations
	animated_sprite.play("idle")

# Plays footstep sounds (looping)
func play_footsteps(sound_type: String):
	# Lazy initialization if _ready() wasn't called
	if footstep_player == null:
		footstep_player = AudioStreamPlayer.new()
		footstep_player.bus = "reverb"
		add_child(footstep_player)

	# Only change if different sound needed
	if current_footstep_sound == sound_type and footstep_player.playing:
		return

	current_footstep_sound = sound_type

	# Get the sound from AudioPlayer's sfx_collections
	if sound_type in AudioPlayer.sfx_collections:
		var sounds = AudioPlayer.sfx_collections[sound_type]
		if sounds.size() > 0:
			footstep_player.stream = sounds[0]  # Use first sound in collection
			if not footstep_player.playing:
				footstep_player.play()

# Stops footstep sounds
func stop_footsteps():
	if footstep_player != null and footstep_player.playing:
		footstep_player.stop()
	current_footstep_sound = ""

# Plays push sound (looping)
func play_push_sound():
	# Lazy initialization if _ready() wasn't called
	if push_player == null:
		push_player = AudioStreamPlayer.new()
		push_player.bus = "reverb"
		push_player.volume_db = -10.0
		add_child(push_player)

	# Only start if not already playing
	if not push_player.playing:
		if "push" in AudioPlayer.sfx_collections:
			var sounds = AudioPlayer.sfx_collections["push"]
			if sounds.size() > 0:
				push_player.stream = sounds[0]
				push_player.play()

# Stops push sound
func stop_push_sound():
	if push_player != null and push_player.playing:
		push_player.stop()

func get_speed() -> float:
	return velocity.length()
	
## Virtual input method, children override. This is used to check for inputs (jump/pickup/dash)
## In the state machine while differentiating between pressing the button and reading a recording
func is_action_pressed_virtual(action: String) -> bool:
	return false

## Virtual input method, children override. This is used to check for inputs (jump/pickup/dash)
## In the state machine while differentiating between pressing the button and reading a recording
func is_action_just_pressed_virtual(action: String) -> bool:
	return false
