class_name LandingCarryPlayerState
extends BasePlayerState

func enter(player: CharacterBase) -> void:
	player.animated_sprite.play("landing_carry_box")
	AudioPlayer.play_sfx("landing")
		# If for some reason player has picked up a box mid air after dashing or double jumping
	player.has_used_dash = false
	player.used_double_jump = false


func exit(player: CharacterBase) -> void:
	pass


func pre_update(player: CharacterBase) -> void:
	if player.is_action_just_pressed_virtual("jump"):
		player.change_state_to(PlayerStates.JUMP_CARRY)
	if not player.animated_sprite.is_playing():
		player.change_state_to(PlayerStates.IDLE_CARRY)
		
	if player.is_action_just_pressed_virtual("pick_up"):
		if abs(player.velocity.x) < 50:
			player.change_state_to(PlayerStates.PLACE_DOWN)
		else:
			player.change_state_to(PlayerStates.THROW)


func update(player: CharacterBase, delta: float) -> void:
	player.velocity += player.get_gravity() * delta
