extends CharacterBase

var spawn_position: Vector2
var recorded_inputs: Array = []
var frame_index: int = 0
var direction: float = 0.0

func _physics_process(delta: float) -> void:
	
	if frame_index < recorded_inputs.size():
		var frame_data = recorded_inputs[frame_index]
		direction  = frame_data["direction"]
		var jump_pressed: bool = frame_data["jump"]
		var double_jump: bool = frame_data.get("double_jump", false)
		var pick_up_pressed: bool = frame_data.get("pick_up", false)
		is_sprinting = frame_data.get("sprint", false)
	
		# Handle box interaction
		if pick_up_pressed:
			handle_box_interraction()
	
		# Handle jump.
		if jump_pressed:
			if is_on_floor():
				start_jump()
				used_double_jump = false
			elif can_wall_jump():
				start_jump()
			elif double_jump and can_double_jump and not used_double_jump:
				start_jump()
				used_double_jump = true
		
		# Physics handled in super class
		super._physics_process(delta)
				
		frame_index += 1
		
	else:
		# Finished playback
		if not is_dead:
			
			if carried_box != null:
				carried_box.place_down(facing_direction)
				carried_box = null
			
			animated_sprite.play("die")

func get_direction() -> float:
	return direction
	
# Resets the playback of the echo and starts the playback again from frame 0
func reset_playback():
	frame_index = 0
	global_position = spawn_position
	velocity = Vector2.ZERO
	jumping = false
	falling = false
	landing = false
	is_sprinting = false
	used_double_jump = false
	is_dead = false
	
	# Drop carried box if holding
	if carried_box != null:
		carried_box = null
	
	# Restart animation
	if animated_sprite.sprite_frames.has_animation("idle"):
		animated_sprite.play("idle")				
