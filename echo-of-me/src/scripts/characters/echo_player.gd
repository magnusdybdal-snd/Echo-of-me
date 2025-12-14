extends CharacterBase

var spawn_position: Vector2
var recorded_inputs: Array = []
var frame_index: int = 0
var direction: float = 0.0
var in_cutscene := false 

func _physics_process(delta: float) -> void:
	if in_cutscene: # no physics in cutscene
		return
	
	if frame_index < recorded_inputs.size():
		frame_index += 1
	else:
		# Finished playback go to idle state
		if carried_box != null and state != PlayerStates.IDLE_CARRY:
			change_state_to(PlayerStates.IDLE_CARRY)
		elif carried_box == null and state != PlayerStates.IDLE:
			change_state_to(PlayerStates.IDLE)
	# Apply physics, handled in super class
	super._physics_process(delta)


func get_direction() -> float:
	if frame_index < recorded_inputs.size():
		return recorded_inputs[frame_index].get("direction", false)
	return 0.0
# Resets the playback of the echo and starts the playback again from frame 0
func reset_playback():
	frame_index = 0
	global_position = spawn_position
	velocity = Vector2.ZERO
	used_double_jump = false
	has_used_dash = false
	change_state_to(PlayerStates.IDLE)

func set_animation(anim_name: String):
	animated_sprite.play(anim_name)
	
func start_cutscene():
	in_cutscene = true
	velocity = Vector2.ZERO 
	
func end_cutscene():
	in_cutscene = false
	
func is_action_pressed_virtual(action: String) -> bool:
	if frame_index < recorded_inputs.size():
		return recorded_inputs[frame_index].get(action, false)
	return false

func is_action_just_pressed_virtual(action: String) -> bool:
	if frame_index < recorded_inputs.size():
		return recorded_inputs[frame_index].get(action, false)
	return false
