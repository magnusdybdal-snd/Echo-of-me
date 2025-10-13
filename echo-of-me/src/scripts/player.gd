extends CharacterBase

var spawn_position: Vector2


# Used to control the recording system for echoes
var recording: Array = []
var frame_index := 0
var is_recording := true

func _ready():
	# Stores spawn position for resets
	spawn_position = global_position
	var level_controller = get_tree().current_scene.get_node("LevelController")
	level_controller.connect("reset_level", Callable(self, "_on_reset_level"))

func _physics_process(delta: float) -> void:
	# Echo recording system
	if is_recording:
		record_input()

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		start_jump()
		velocity.y = JUMP_VELOCITY

	super._physics_process(delta)
	
	# Applies the movement
	if get_direction():
		velocity.x = get_direction() * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	

# Overridden function from master class. Gets the direction of player for animation control
func get_direction() -> float:
	return Input.get_axis("move_left", "move_right")

# Reacts to signal from level controller
func _on_reset_level():
	reset_player()
	
# Resets the players position, flags and recording system
func reset_player():
	global_position = spawn_position
	velocity = Vector2.ZERO
	jumping = false
	falling = false
	landing = false
	animated_sprite.play("idle")
	clear_recording()

# Appends player inputs to the recording for later echo spawn / mimic	
func record_input() -> void:
	recording.append({
		"frame": frame_index,
		"direction": Input.get_axis("move_left", "move_right"),
		"jump": Input.is_action_just_pressed("jump")
	})
	frame_index += 1

# Clears the recorded inputs
func clear_recording():
	recording.clear()
	frame_index = 0
