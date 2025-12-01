# character_base.gd

extends CharacterBody2D
class_name CharacterBase

# Constants for player movement and forces
const SPEED := 150.0
const CARRY_SPEED := 130
const SPRINT_SPEED := 210.0
const ACCELERATION := 1300.0
const FRICTION := 2000.0
const AIR_RESISTANCE := 400
const JUMP_VELOCITY := -370.0
const SECOND_JUMP_VELOCITY := -270
const CARRY_JUMP_VELOCITY := -270.0
const BOX_PUSH_SPEED := 300.0

# Wall climb constants
const WALL_SLIDE_GRAVITY := 55.0 # How fast you will slide down the wall
const WALL_JUMP_FORCE := 200 # Push force off the wall when jumping
const WALL_JUMP_GRACE_TIME := 0.2 # Grace period after leaaving wall (seconds)

# Dash constants
const DASH_FORCE := 400.0 # Horizontal velocity applied when dashing
const DASH_DURATION := 0.2 # How long the dash lasts in seconds

# Used to control animations
var falling := false
var is_sprinting := false
var is_dead := false
var anim_lock := false
var is_dashing := false
var has_used_dash := false

# Cached powerup states
var can_sprint := false
var can_double_jump := false
var can_wall_climb := false
var used_double_jump := false
var can_dash := false

# Wall jump coyote time
var wall_jump_timer := 0.0
var last_wall_normal := Vector2.ZERO

# Dash timer
var dash_timer := 0.0

# Tracks boxes to apply push force to
var nearby_boxes: Array = []

# Box currently beeing carried
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

func _ready():
	# Create footstep audio player
	footstep_player = AudioStreamPlayer.new()
	footstep_player.bus = "reverb"
	add_child(footstep_player)

	# Create push sound player
	push_player = AudioStreamPlayer.new()
	push_player.bus = "reverb"
	push_player.volume_db = -10.0
	add_child(push_player)

func _physics_process(delta):
	if is_dead:
		return 
	if "in_cutscene" in self and self.in_cutscene:
		move_and_slide()  # Still allow AnimationPlayer to move the character
		return

	check_powerups()
	update_wall_jump_timer(delta)
	update_dash_timer(delta)
	apply_gravity(delta)
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
	
# Applies gravity to the characters when in air
func apply_gravity(delta: float) -> void:
	# Don't apply gravity while dashing
	if is_dashing:
		return

	# If player is in contact with a wall, apply sliding gravity
	if is_on_wall_only() and velocity.y > 0 and can_wall_climb:
		velocity.y = WALL_SLIDE_GRAVITY
	# Otherwise normal world gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
		
# Acceleration based movement system
func apply_movement(delta: float) -> void:
	var direction = get_direction()
	
	var target_speed := 0.0
	var is_pushing := false
	
	if direction != 0:
		is_pushing = is_pushing_box(direction)

		if is_pushing:
			# Cap speed to the speed of the box while pushing
			target_speed = BOX_PUSH_SPEED * direction
			play_push_sound()
		else:
			if is_on_floor():
				# Normal movement speed
				if (can_sprint and is_sprinting and carried_box == null):
					target_speed = SPRINT_SPEED
				elif (carried_box != null):
					target_speed = CARRY_SPEED
				else:
					target_speed = SPEED
			# Air speed
			else:
				if abs(velocity.x) > SPEED and carried_box == null:
					target_speed = SPRINT_SPEED
				elif carried_box != null:
					target_speed = CARRY_SPEED
				else:
					target_speed = SPEED
					
			target_speed *= direction
				
	
	var accel_rate: float
	
	if direction != 0:
		accel_rate = ACCELERATION
	else:
		if is_on_floor():
			accel_rate = FRICTION
		else:
			accel_rate = AIR_RESISTANCE

	velocity.x = move_toward(velocity.x, target_speed, accel_rate * delta)

	# Stop push sound when not pushing
	if not is_pushing:
		stop_push_sound()

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

# This function handles update of animations related to physics
func update_animation(direction: float) -> void:

	# Flips sprite based on the direction the character is facing
	if direction > 0:
		animated_sprite.flip_h = false
		facing_direction = 1.0
	elif direction < 0:
		animated_sprite.flip_h = true
		facing_direction = -1.0

	# ON GROUND ANIMATIONS
	if is_on_floor():
		# Just landed
		if falling and !anim_lock:
			falling = false
			anim_lock = true
			AudioPlayer.play_sfx("landing")
			if !carried_box:
				animated_sprite.play("landing")
			else:
				animated_sprite.play("landing_carry_box")
		# On ground not jumping/falling -> play walk or idle
		elif !anim_lock:
			# Animations when carrying a box
			if carried_box:
				if direction == 0:
					animated_sprite.play("idle_carry_box")
					stop_footsteps()
				else:
					animated_sprite.play("walk_carry_box")
					play_footsteps("walk")
			# Animations when not carrying a box
			else:
				if direction == 0:
					animated_sprite.play("idle")
					stop_footsteps()
				elif can_sprint and is_sprinting:
					animated_sprite.play("run")
					play_footsteps("run")
				else:
					animated_sprite.play("walk")
					play_footsteps("walk")
	else:
		# IN AIR ANIMATIONS
		stop_footsteps()  # Stop footsteps when in air
		if !anim_lock:
			if carried_box:
				animated_sprite.play("in_air_carry_box")
			elif is_on_wall_only() and can_wall_climb and velocity.y > 0:
				animated_sprite.play("wall_slide")
			else:
				animated_sprite.play("in air")
		if velocity.y > 0:
			falling = true

# Sets flags for animation control and plays jump animation
func start_jump():
	if is_dead:
		return
	anim_lock = true
	falling = false
	AudioPlayer.play_sfx("jump", -6.0)
	if can_wall_jump():
		# Use stored wall normal from last wall contact
		velocity.x = last_wall_normal.x * WALL_JUMP_FORCE
		velocity.y = JUMP_VELOCITY

		animated_sprite.play("jump")

	elif carried_box:
		animated_sprite.play("jump_carry_box")
		velocity.y = CARRY_JUMP_VELOCITY

	else:
		velocity.y = JUMP_VELOCITY if is_on_floor() else JUMP_VELOCITY + 100
		animated_sprite.play("jump")

# Performs a dash in the direction the character is facing
func perform_dash():
	# Apply dash velocity in the facing direction (horizontal only)
	velocity.x = DASH_FORCE * facing_direction
	velocity.y = 0  # Cancel vertical velocity for horizontal dash
	is_dashing = true
	has_used_dash = true
	dash_timer = DASH_DURATION

	anim_lock = true
	animated_sprite.play("dash")
	AudioPlayer.play_sfx("dash")

# Makes sure animations finish before physics process takes over by toggeling animation lock
func _on_animated_sprite_2d_animation_finished() -> void:
	anim_lock = false
	print("anim unlocked")
				
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
	# Cannot pick up again before animation is complete
	if anim_lock:
		print("PICKUP BLOCKED - anim_lock is true, current animation: ", animated_sprite.animation)
		return

	if carried_box != null:
		# Already carrying, place or throw
		var is_moving = abs(velocity.x) > 10
		
		if is_moving:
			# Take the animation lock and ply the animation. Throw and place animation 
			# Always overgo other animations so we do not check lock
			anim_lock = true
			animated_sprite.play("throw")
			# Throw the box
			var throw_dir = sign(velocity.x)
			carried_box.throw_box(throw_dir, velocity)
		else:
			# Place down gently
			carried_box.place_down(facing_direction)
			# Take the animation lock and play the animation
			anim_lock = true
			animated_sprite.play("place_down")
		# Reset state of carried box
		carried_box = null
	
	else:
		# Try to pick up nearby boxa 
		var nearest_box = find_nearest_box()
		if nearest_box != null and nearest_box.has_method("pick_up"):
			nearest_box.pick_up(self)
			carried_box = nearest_box
						
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
