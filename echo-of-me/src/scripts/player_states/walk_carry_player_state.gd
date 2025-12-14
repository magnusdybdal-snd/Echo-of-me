class_name WalkCarryPlayerState
extends BasePlayerState

const CARRY_SPEED := 130

func enter(player: CharacterBase) -> void:
	player.animated_sprite.play("walk_carry_box")
	player.play_footsteps("walk")
	player.target_speed = CARRY_SPEED

func exit(player: CharacterBase) -> void:
	player.stop_footsteps()


func pre_update(player: CharacterBase) -> void:
	if player.is_action_just_pressed_virtual("jump"):
		player.change_state_to(PlayerStates.JUMP_CARRY)
	if player.get_direction() == 0:
		player.change_state_to(PlayerStates.IDLE_CARRY)
	
	if player.get_direction() != 0 and player.is_action_just_pressed_virtual("pick_up"):
		player.change_state_to(PlayerStates.THROW)
		return

	# Start coyote time when leaving ground, only fall when it expires
	if not player.is_on_floor():
		if player.cyote_time_remaining <= 0 and player.velocity.y > 0:
			player.change_state_to(PlayerStates.FALL_CARRY)


func update(player: CharacterBase, delta: float) -> void:
	player.velocity += player.get_gravity() * delta

	# Count down coyote time when not on floor
	if not player.is_on_floor():
		if player.cyote_time_remaining > 0:
			player.cyote_time_remaining -= delta
	else:
		# Reset coyote time when on floor
		player.cyote_time_remaining = player.CYOTEE_GRACE_TIME
