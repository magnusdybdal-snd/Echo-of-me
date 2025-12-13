class_name RunPlayerState
extends BasePlayerState

func enter(player: CharacterBase) -> void:
	player.animated_sprite.play("run")
	player.play_footsteps("run")
	
func exit(player: CharacterBase) -> void:
	player.stop_footsteps()
	
func pre_update(player: CharacterBase) -> void:	
	var direction := player.get_direction()
	
	if Input.is_action_just_pressed("jump"):
		player.change_state_to(PlayerStates.JUMP)
	
	if not Input.is_action_pressed("sprint"):
		player.change_state_to(PlayerStates.WALK)
		
	if direction == 0:
		player.change_state_to(PlayerStates.IDLE)
	

func update(player: CharacterBase, delta: float) -> void:
	pass
