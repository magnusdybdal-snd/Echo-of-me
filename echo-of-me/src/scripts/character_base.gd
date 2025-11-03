# character_base.gd

extends CharacterBody2D
class_name CharacterBase

# Constants for player movement and forces
const SPEED := 200.0
const SPRINT_SPEED := 300.0
const ACCELERATION := 800.0
const SPRINT_ACCELERATION := 1000.0
const FRICTION := 2000.0
const AIR_RESISTANCE := 100.0
const JUMP_VELOCITY := -370.0
const BOX_PUSH_SPEED := 150.0

# Used to control animations
var jumping := false
var falling := false
var landing := false
var is_sprinting := false
var is_dead := false

# Cached powerup states
var can_sprint := false
var can_double_jump := false

# Tracks boxes to apply push force to
var nearby_boxes: Array = []

@onready var animated_sprite = %AnimatedSprite2D

func _physics_process(delta):
	if is_dead:
		return  
	check_powerups()
	apply_gravity(delta)
	apply_movement(delta)
	update_animation(get_direction())
	push_boxes()
	move_and_slide()
	
func check_powerups() -> void:
	can_sprint = GameManager.has_powerup("sprint")
	can_double_jump = GameManager.has_powerup("double_jump")
	
# Applies gravity to the characters when in air
func apply_gravity(delta: float) -> void:
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
		
		else:
			# Normal movement speed
			target_speed = SPRINT_SPEED if (can_sprint and is_sprinting and is_on_floor()) else SPEED
			target_speed *= direction
	
	var accel_rate: float
	if is_on_floor():
		if direction != 0:
			accel_rate = SPRINT_ACCELERATION if can_sprint and  is_sprinting else ACCELERATION
		else:
			accel_rate = FRICTION
	else:
		accel_rate = AIR_RESISTANCE
	
	velocity.x = move_toward(velocity.x, target_speed, accel_rate * delta)

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

# This function handles update of animations as the characters share a lot of animations
func update_animation(direction: float) -> void:

	# Flips sprite based on the direction the character is facing
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	if is_on_floor():
		# Just landed
		if falling:
			jumping = false
			falling = false
			landing = true
			animated_sprite.play("landing")
		elif not jumping and not landing:
			# On ground not jumping/falling -> play walk or idle
			if direction == 0 :
				animated_sprite.play("idle")
			
			elif can_sprint and is_sprinting:
				animated_sprite.play("run")
			
			else:
				animated_sprite.play("walk")
				
	
	else:
		# In air
		if not jumping:
			animated_sprite.play("in air")
		if velocity.y > 0:
			falling = true

# Sets flags for animation control and plays jump animation
func start_jump():
	velocity.y = JUMP_VELOCITY
	jumping = true
	falling = false
	animated_sprite.play("jump")

# Makes sure the jumping and landing animation finishes before playing the falling animation
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "jump":
		jumping = false
		if not is_on_floor():
			animated_sprite.play("in air")
			
	elif animated_sprite.animation == "landing":
		landing = false
		animated_sprite.play("idle")
				
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
			
		print("Player velocity: ", velocity.x, " | Box velocity: ", box.linear_velocity.x)
			
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
	is_dead = true
		
	velocity = Vector2.ZERO
	
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
