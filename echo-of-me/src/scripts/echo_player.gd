extends CharacterBase

var spawn_position: Vector2
var recorded_inputs: Array = []
var frame_index: int = 0
var direction: float = 0.0
var in_cutscene := false 

func _ready() -> void:
	is_echo = true

func _physics_process(delta: float) -> void:
	if in_cutscene: # no physics in cutscene
		return
	
	if frame_index < recorded_inputs.size():
		var frame_data = recorded_inputs[frame_index]
		direction  = frame_data["direction"]
		var is_sprinting = frame_data.get("sprint", false)
		var jump_pressed: bool = frame_data["jump"]
		var double_jump: bool = frame_data.get("double_jump", false)
		var pick_up_pressed: bool = frame_data.get("pick_up", false)
		var dash_pressed: bool = frame_data.get("dash", false)

		# Handle box interaction
		if pick_up_pressed:
			handle_box_interraction()

		# Handle dash (only in air, not on ground or wall)
		if dash_pressed and can_dash and not is_on_floor() and not is_on_wall_only() and not has_used_dash:
			#perform_dash()
			pass
		
		# Physics handled in super class
		super._physics_process(delta)
				
		frame_index += 1
		
	else:
		# Finished playback
		if not is_dead:
			
			if carried_box != null:
				carried_box.place_down(facing_direction)
				carried_box = null
			
			animated_sprite.play("idle")

func get_direction() -> float:
	return direction
	
# Resets the playback of the echo and starts the playback again from frame 0
func reset_playback():
	frame_index = 0
	global_position = spawn_position
	velocity = Vector2.ZERO
	anim_lock = false
	#falling = false
	#is_sprinting = false
	used_double_jump = false
	is_dead = false
	is_dashing = false
	has_used_dash = false
	dash_timer = 0.0

	# Drop carried box if holding
	if carried_box != null:
		carried_box = null

	# Restart animation
	if animated_sprite.sprite_frames.has_animation("idle"):
		animated_sprite.play("idle")				
func set_animation(anim_name: String):
	animated_sprite.play(anim_name)
	
func start_cutscene():
	in_cutscene = true
	velocity = Vector2.ZERO 
	print("Start of echo cutscene")
	
func end_cutscene():
	in_cutscene = false
	print("end echo cutscene")
	
func is_action_pressed_virtual(action: String) -> bool:
	if frame_index < recorded_inputs.size():
		return recorded_inputs[frame_index].get(action, false)
	return false

func is_action_just_pressed_virtual(action: String) -> bool:
	if frame_index < recorded_inputs.size():
		return recorded_inputs[frame_index].get(action, false)
	return false
