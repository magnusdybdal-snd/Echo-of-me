class_name WalkCarryPlayerState
extends BasePlayerState

func enter(player: CharacterBase) -> void:
	player.animated_sprite.play("walk_carry_box")
	player.play_footsteps("walk")


func exit(player: CharacterBase) -> void:
	player.stop_footsteps()



func pre_update(player: CharacterBase) -> void:
	if Input.is_action_just_pressed("jump"):
		player.change_state_to(PlayerStates.JUMP_CARRY)
	if player.velocity.x == 0:
		player.change_state_to(PlayerStates.IDLE_CARRY)


func update(player: CharacterBase, delta: float) -> void:
	pass
