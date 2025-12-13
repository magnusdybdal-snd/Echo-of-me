class_name RunPlayerState
extends BasePlayerState

func enter(player: CharacterBase) -> void:
	player.animated_sprite.play("run")
	player.play_footsteps("run")
	
func exit(player: CharacterBase) -> void:
	pass
	
func pre_update(player: CharacterBase) -> void:	
	if Input.is_action_just_pressed("jump"):
		player.change_state_to(PlayerStates.JUMP)
	
	if not Input.is_action_pressed("sprint"):
		player.change_state_to(PlayerStates.WALK)

func update(player: CharacterBase, delta: float) -> void:
	pass
