# character_base.gd

extends CharacterBody2D
class_name CharacterBase

# Constants for player movement and forces
const SPEED := 200.0
const JUMP_VELOCITY := -370.0
const PUSH_FORCE := 100.0

# Used to control animations
var jumping := false
var falling := false
var landing := false

@onready var animated_sprite = %AnimatedSprite2D

func _physics_process(delta):
	apply_gravity(delta)
	update_animation(get_direction())
	push_boxes()
	move_and_slide()	

# Applies gravity to the characters when in air
func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

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
			animated_sprite.play("idle" if direction == 0 else "walk")
	
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

# Controls how the character will interact with rigid bodies (boxes)
func push_boxes() -> void:
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			c.get_collider().apply_central_force(-c.get_normal() * PUSH_FORCE * 15)
			if "signal_push" in c.get_collider():
				c.get_collider().signal_push()


# Abstract method overridden by children
func get_direction() -> float:
	return 0.0
