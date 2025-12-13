class_name LandingCarryPlayerState
extends BasePlayerState

func enter(player: CharacterBase) -> void:
	player.animated_sprite.play("landing_carry_box")
	AudioPlayer.play_sfx("landing")


func exit(player: CharacterBase) -> void:
	# If for some reason player has picked up a box mid air after dashing
	player.has_used_dash = false



func pre_update(player: CharacterBase) -> void:
	if not player.animated_sprite.is_playing():
		player.change_state_to(PlayerStates.IDLE_CARRY)


func update(player: CharacterBase, delta: float) -> void:
	pass
