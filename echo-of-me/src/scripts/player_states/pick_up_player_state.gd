class_name PickUpPlayerState
extends BasePlayerState

func enter(player: CharacterBase) -> void:
	player.pick_up_target.pick_up(player)
	player.carried_box = player.pick_up_target

func exit(player: CharacterBase) -> void:
	pass


func pre_update(player: CharacterBase) -> void:
	player.change_state_to(PlayerStates.IDLE_CARRY)


func update(player: CharacterBase, delta: float) -> void:
	pass
