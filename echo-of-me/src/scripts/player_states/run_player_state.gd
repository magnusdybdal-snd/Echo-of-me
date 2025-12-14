class_name RunPlayerState
extends BasePlayerState

const SPRINT_SPEED := 210.0

func enter(player: CharacterBase) -> void:
	player.animated_sprite.play("run")
	player.play_footsteps("run")
	player.target_speed = SPRINT_SPEED
	
func exit(player: CharacterBase) -> void:
	player.stop_footsteps()
	
func pre_update(player: CharacterBase) -> void:	
	var direction := player.get_direction()
	
	if player.is_action_just_pressed_virtual("jump"):
		player.change_state_to(PlayerStates.JUMP)
	
	if not player.is_action_pressed_virtual("sprint"):
		player.change_state_to(PlayerStates.WALK)
		
	if direction == 0:
		player.change_state_to(PlayerStates.IDLE)

	# Start coyote time when leaving ground, only fall when it expires
	if not player.is_on_floor():
		if player.cyote_time_remaining <= 0 and player.velocity.y > 0:
			player.change_state_to(PlayerStates.FALL)
	

func update(player: CharacterBase, delta: float) -> void:
	player.velocity += player.get_gravity() * delta

	# Count down coyote time when not on floor
	if not player.is_on_floor():
		if player.cyote_time_remaining > 0:
			player.cyote_time_remaining -= delta
	else:
		# Reset coyote time when on floor
		player.cyote_time_remaining = player.CYOTEE_GRACE_TIME
