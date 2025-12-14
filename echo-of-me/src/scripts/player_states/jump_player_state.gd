class_name JumpPlayerState
extends BasePlayerState

const JUMP_VELOCITY := -370.0
const SECOND_JUMP_VELOCITY := -270

func enter(player: CharacterBase) -> void:
	# If we still have coyote time, treat as ground jump
	if player.is_on_floor() or player.cyote_time_remaining > 0:
		player.velocity.y = JUMP_VELOCITY
		player.cyote_time_remaining = 0.0  # Consume coyote time
	else:
		player.velocity.y = SECOND_JUMP_VELOCITY
		player.used_double_jump = true
	player.animated_sprite.play("jump")
	AudioPlayer.play_sfx("jump")


func exit(player: CharacterBase) -> void:
	pass


func pre_update(player: CharacterBase) -> void:
	var can_dash = not player.has_used_dash and player.can_dash
	if player.velocity.y > 0:
		player.change_state_to(PlayerStates.FALL)

	if player.is_action_just_pressed_virtual("dash") and can_dash:
		player.change_state_to(PlayerStates.DASH)
		return
		
	if player.is_action_just_pressed_virtual("jump") and player.can_double_jump and not player.used_double_jump:
		player.change_state_to(PlayerStates.JUMP)


func update(player: CharacterBase, delta: float) -> void:
	player.velocity += player.get_gravity() * delta
