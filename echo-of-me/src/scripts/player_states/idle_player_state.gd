class_name IdlePlayerState
extends BasePlayerState

func enter(player: CharacterBase) -> void:
	player.animated_sprite.play("idle")
	
func exit(player: CharacterBase) -> void:
	pass

func pre_update(player: CharacterBase) -> void:
	if not player.is_on_floor():
		player.change_state_to(PlayerStates.FALL)
	
func update(player: CharacterBase, delta: float) -> void:
	pass
