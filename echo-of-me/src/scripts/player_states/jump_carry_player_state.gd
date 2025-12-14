class_name JumpCarryPlayerState
extends BasePlayerState

const CARRY_JUMP_VELOCITY := -270.0
const CARRY_SPEED := 130.0

func enter(player: CharacterBase) -> void:
	player.velocity.y = CARRY_JUMP_VELOCITY
	player.animated_sprite.play("jump_carry_box")
	player.velocity.y = CARRY_JUMP_VELOCITY
	player.target_speed = CARRY_SPEED


func exit(player: CharacterBase) -> void:
	pass


func pre_update(player: CharacterBase) -> void:
	if player.velocity.y > 0:
		player.change_state_to(PlayerStates.FALL_CARRY)
	if player.get_direction() != 0 and player.is_action_just_pressed_virtual("pick_up"):
		player.change_state_to(PlayerStates.THROW)


func update(player: CharacterBase, delta: float) -> void:
	player.velocity += player.get_gravity() * delta
