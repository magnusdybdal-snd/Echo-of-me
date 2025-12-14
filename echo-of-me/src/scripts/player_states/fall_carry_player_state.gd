class_name FallCarryPlayerState
extends BasePlayerState

const CARRY_SPEED := 130.0

func enter(player: CharacterBase) -> void:
	player.stop_footsteps()
	player.animated_sprite.play("in_air_carry_box")
	player.target_speed = CARRY_SPEED


func exit(player: CharacterBase) -> void:
	pass


func pre_update(player: CharacterBase) -> void:
	if player.is_on_floor():
		player.change_state_to(PlayerStates.LANDING_CARRY)
		return


func update(player: CharacterBase, delta: float) -> void:
	player.velocity += player.get_gravity() * delta
