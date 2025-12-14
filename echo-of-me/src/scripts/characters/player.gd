extends CharacterBase

var spawn_position: Vector2

# Used to control the recording system for echoes
var recording: Array = []
var frame_index := 0
var is_recording := false
var in_cutscene := false 

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
	
	# Echo recording system
	if is_recording:
		record_input()

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
	is_dead = false
	has_used_dash = false

	clear_recording()
	change_state_to(PlayerStates.IDLE)

# Appends player inputs to the recording for later echo spawn / mimic	
func record_input() -> void:
	recording.append({
		"frame": frame_index,
		"direction": Input.get_axis("move_left", "move_right"),
		"jump": Input.is_action_just_pressed("jump"),
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
	
func is_action_pressed_virtual(action: String) -> bool:
	return Input.is_action_pressed(action)
	
func is_action_just_pressed_virtual(action: String) -> bool:
	return Input.is_action_just_pressed(action)
