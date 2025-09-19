extends CharacterBody2D


const SPEED = 200.0
const JUMP_VELOCITY = -350.0

@onready var animated_sprite = $AnimatedSprite2D

var jumping = false
var falling = false
var landing = false

func _physics_process(delta: float) -> void:
	
	print("anim:", animated_sprite.animation, "  jumping:", jumping, "  is_on_floor:", is_on_floor())
 
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jumping = true
		falling = false
		animated_sprite.play("jump")

	# Get the input direction (-1, 0, 1)
	var direction := Input.get_axis("move_left", "move_right")
	
	# Flips the sprite based on direction
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
	
	if is_on_floor():
		if falling:
			# just landed
			jumping = false
			falling = false
			landing = true
			animated_sprite.play("landing")
		elif not jumping and not landing:
			if direction == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("walk")
	else:
		#in air
		if not jumping:
			animated_sprite.play("in air")
		if velocity.y > 0:
			falling = true
	
	
	# Applies the movement
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "jump":
		jumping = false
		if not is_on_floor():
			animated_sprite.play("in air")
			
	elif animated_sprite.animation == "landing":
		landing = false
		animated_sprite.play("idle")
