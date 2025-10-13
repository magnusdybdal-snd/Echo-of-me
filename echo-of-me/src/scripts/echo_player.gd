extends CharacterBase

var recorded_inputs: Array = []
var frame_index: int = 0
var direction: float = 0.0

func _physics_process(delta: float) -> void:
	
	if frame_index < recorded_inputs.size():
		var frame_data = recorded_inputs[frame_index]
		direction  = frame_data["direction"]
		var jump_pressed: bool = frame_data["jump"]
	
		# Handle jump.
		if jump_pressed and is_on_floor():
			start_jump()
			
		# Horizontal movement
		velocity.x = direction * SPEED
		
		super._physics_process(delta)
				
		frame_index += 1
		
	else:
		# Finished playback
		animated_sprite.play("die")

func get_direction() -> float:
	return direction
				
