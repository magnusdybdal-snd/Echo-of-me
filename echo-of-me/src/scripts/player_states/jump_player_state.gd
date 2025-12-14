class_name JumpPlayerState
extends BasePlayerState

const JUMP_VELOCITY := -370.0
const SECOND_JUMP_VELOCITY := -270

func enter(player: CharacterBase) -> void:
	player.velocity.y = JUMP_VELOCITY if player.is_on_floor() else SECOND_JUMP_VELOCITY
	player.animated_sprite.play("jump")
	AudioPlayer.play_sfx("jump")


func exit(player: CharacterBase) -> void:
	pass


func pre_update(player: CharacterBase) -> void:
	if player.velocity.y > 0:
		player.change_state_to(PlayerStates.FALL)

	if player.is_action_just_pressed_virtual("dash") and not player.has_used_dash:
		player.change_state_to(PlayerStates.DASH)
		return


func update(player: CharacterBase, delta: float) -> void:
	player.velocity += player.get_gravity() * delta
