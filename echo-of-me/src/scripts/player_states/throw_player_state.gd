class_name ThrowPlayerState
extends BasePlayerState

func enter(player: CharacterBase) -> void:
	pass


func exit(player: CharacterBase) -> void:
	player.pick_up_target = null
	player.carried_box = null


func pre_update(player: CharacterBase) -> void:
	pass


func update(player: CharacterBase, delta: float) -> void:
	pass
