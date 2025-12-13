class_name IdlePlayerState
extends BasePlayerState

func enter(player: CharacterBase) -> void:
	player.animated_sprite.play("idle")
	
func exit(player: CharacterBase) -> void:
	pass

## Handles transition rules between states
func pre_update(player: CharacterBase) -> void:
	var current_speed = player.get_current_speed()
	
	if not player.is_on_floor():
		player.change_state_to(PlayerStates.FALL)
	elif player.get_direction() != 0:
		player.change_state_to(PlayerStates.WALK)
	
	
func update(player: CharacterBase, delta: float) -> void:
	pass
