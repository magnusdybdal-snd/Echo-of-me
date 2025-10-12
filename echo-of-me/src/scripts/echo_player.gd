extends CharacterBody2D

var recorded_inputs: Array = []
var frame_index: int = 0

const SPEED := 200.0
const JUMP_VELOCITY := -370.0
const PUSH_FORCE := 50.0

@onready var animated_sprite = %AnimatedSprite2D_echo

var jumping := false
var falling := false
var landing := false

func _physics_process(delta: float) -> void:
	
	if frame_index < recorded_inputs.size():
		var frame_data = recorded_inputs[frame_index]
		var dir: float = frame_data["direction"]
		var jump_pressed: bool = frame_data["jump"]
	
	
		# Apply gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta

		# Handle jump.
		if jump_pressed and is_on_floor():
			velocity.y = JUMP_VELOCITY
			jumping = true
			falling = false
			animated_sprite.play("jump")
			
		# Horizontal movement
		velocity.x = dir * SPEED
		move_and_slide()
		
		# Flips the sprite based on direction
		if dir > 0:
			animated_sprite.flip_h = false
		elif dir < 0:
			animated_sprite.flip_h = true
			
		# Handles which animation to play
		if is_on_floor():
			if falling:
				# just landed
				jumping = false
				falling = false
				landing = true
				animated_sprite.play("landing")
			elif not jumping and not landing:
				if dir == 0:
					animated_sprite.play("idle")
				else:
					animated_sprite.play("walk")
		else:
			#in air
			if not jumping:
				animated_sprite.play("in air")
			if velocity.y > 0:
				falling = true
				
			# Handles pushing of rigid bodies (boxes) - ADD THIS SECTION
		for i in get_slide_collision_count():
			var c = get_slide_collision(i)
			if c.get_collider() is RigidBody2D:
				c.get_collider().apply_central_impulse(-c.get_normal() * PUSH_FORCE)
				
		frame_index += 1
		
	else:
		# Finished playback
		animated_sprite.play("die")
				
# Makes sure the jumping and landing animation finishes before playing the falling animation
func _on_animated_sprite_2d_echo_animation_finished() -> void:
	if animated_sprite.animation == "jump":
		jumping = false
		if not is_on_floor():
			animated_sprite.play("in air")
			
	elif animated_sprite.animation == "landing":
		landing = false
		animated_sprite.play("idle")
