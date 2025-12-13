class_name JumpCarryPlayerState
extends BasePlayerState

const CARRY_JUMP_VELOCITY := -270.0

func enter(player: CharacterBase) -> void:
	player.animated_sprite.play("jump_carry_box")
	player.velocity.y = CARRY_JUMP_VELOCITY


func exit(player: CharacterBase) -> void:
	pass


func pre_update(player: CharacterBase) -> void:
	pass


func update(player: CharacterBase, delta: float) -> void:
	pass
