class_name FallPlayerState
extends BasePlayerState

func enter(player: CharacterBase) -> void:
	player.stop_footsteps()
	player.animated_sprite.play("in air")

func exit(player: CharacterBase) -> void:
	pass

func pre_update(player: CharacterBase) -> void:
	var can_dash = not player.has_used_dash and player.can_dash
	if player.is_on_floor():
		player.change_state_to(PlayerStates.LANDING)
		return
	
	if player.is_action_just_pressed_virtual("dash") and can_dash:
		player.change_state_to(PlayerStates.DASH)
		return

	# Only handle double jump in FALL (coyote time handled in WALK/RUN)
	if player.is_action_just_pressed_virtual("jump") and player.can_double_jump and not player.used_double_jump:
		player.change_state_to(PlayerStates.JUMP)


func update(player: CharacterBase, delta: float) -> void:
	player.velocity += player.get_gravity() * delta
