extends CharacterBody2D

const SPEED := 200.0
const JUMP_VELOCITY := -370.0 
# Force the player applies to rigid bodies when colliding
const PUSH_FORCE := 200.0
const MIN_PUSH_FORCE := 20

@onready var animated_sprite = %AnimatedSprite2D_player

var spawn_position: Vector2

# Used to control animations
var jumping := false
var falling := false
var landing := false

# Used to control the recording system for echoes
var recording: Array = []
var frame_index := 0
var is_recording := true

func _ready():
	spawn_position = global_position
	var level_controller = get_tree().current_scene.get_node("LevelController")
	level_controller.connect("reset_level", Callable(self, "_on_reset_level"))

func _physics_process(delta: float) -> void:
	 
	# Echo recording system
	if is_recording:
		var input_frame = {
			"frame": frame_index,
			"direction": Input.get_axis("move_left", "move_right"),
			"jump": Input.is_action_just_pressed("jump")
		}
		recording.append(input_frame)
		frame_index += 1
	
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
	
	# Handles which animation to play
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
			
	# Handles pushing of rigid bodies (boxes)
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D:
			var push_force = (PUSH_FORCE * velocity.length() / SPEED) + MIN_PUSH_FORCE
			c.get_collider().apply_central_impulse(-c.get_normal() * push_force)


# Makes sure the jumping and landing animation finishes before playing the falling animation
func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "jump":
		jumping = false
		if not is_on_floor():
			animated_sprite.play("in air")
			
	elif animated_sprite.animation == "landing":
		landing = false
		animated_sprite.play("idle")
		
func _on_reset_level():
	reset_player()
	
func reset_player():
	global_position = spawn_position
	velocity = Vector2.ZERO
	jumping = false
	falling = false
	landing = false
	animated_sprite.play("idle")
	clear_recording()
	
func clear_recording():
	recording.clear()
	frame_index = 0


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("PhysicsObjects"):
		body.collision_layer = 4
		print("entered body")
		body.collision_mask = 4

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("PhysicsObjects"):
		body.collision_layer = 1
		print("left body")
		body.collision_mask = 1
