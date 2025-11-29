extends CharacterBase

var spawn_position: Vector2

# Used to control the recording system for echoes
var recording: Array = []
var frame_index := 0
var is_recording := false
var in_cutscene := false 
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"

func _ready():
	super._ready()  # Call parent class initialization
	# Stores spawn position for resets
	spawn_position = global_position
	var level_controller = get_tree().current_scene.get_node("LevelController")
	level_controller.connect("reset_level", Callable(self, "_on_reset_level"))
	


func _physics_process(delta: float) -> void:
	if in_cutscene:
		return
	# Only record if echo mechanic is unlocked
	is_recording = GameManager.can_use_echoes()
	
	# Check sprint input
	is_sprinting = Input.is_action_pressed("sprint") and is_on_floor()
	
	# Q key to pick up / throw / place box
	if Input.is_action_just_pressed("pick_up"):
		handle_box_interraction()

	# S key to dash (only in air, not on ground or wall)
	if Input.is_action_just_pressed("dash") and can_dash and not is_on_floor() and not is_on_wall_only() and not has_used_dash:
		perform_dash()

	# Echo recording system
	if is_recording:
		record_input()

	# Handle jump.
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			start_jump()
			
			used_double_jump = false
		elif can_double_jump and not used_double_jump and not can_wall_jump():
			start_jump()
			used_double_jump = true
		elif can_wall_jump():
			start_jump()

	# Base class handles all movement
	super._physics_process(delta)
	
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
	anim_lock = false
	falling = false
	is_sprinting = false
	is_dead = false
	is_dashing = false
	has_used_dash = false
	dash_timer = 0.0

	if carried_box != null:
		carried_box.place_down(facing_direction)
		carried_box = null

	animated_sprite.play("idle")
	clear_recording()

# Appends player inputs to the recording for later echo spawn / mimic	
func record_input() -> void:
	recording.append({
		"frame": frame_index,
		"direction": Input.get_axis("move_left", "move_right"),
		"jump": Input.is_action_just_pressed("jump"),
		"double_jump": Input.is_action_just_pressed("jump") and not used_double_jump,
		"sprint": Input.is_action_pressed("sprint"),
		"pick_up": Input.is_action_just_pressed("pick_up"),
		"dash": Input.is_action_just_pressed("dash")
	})
	frame_index += 1

# Clears the recorded inputs
func clear_recording():
	recording.clear()
	frame_index = 0

func set_animation(anim_name: String):
	animated_sprite.play(anim_name)
	
func start_cutscene():
	in_cutscene = true
	velocity = Vector2.ZERO 
	print("Start of cutscene")
	
func end_cutscene():
	in_cutscene = false
	print("end cutscene")
