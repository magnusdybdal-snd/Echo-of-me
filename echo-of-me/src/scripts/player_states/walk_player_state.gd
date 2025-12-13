class_name WalkPlayerState
extends BasePlayerState

func enter(player: CharacterBase) -> void:
	player.animated_sprite.play("walk")
	player.play_footsteps("walk")

func exit(player: CharacterBase) -> void:
	player.stop_footsteps()
	
func pre_update(player: CharacterBase) -> void:
	if Input.is_action_pressed("sprint") and player.can_sprint:
		player.change_state_to(PlayerStates.RUN)
	if Input.is_action_just_pressed("jump"):
		player.change_state_to(PlayerStates.JUMP)
	if player.velocity.x == 0:
		player.change_state_to(PlayerStates.IDLE)
	
func update(player: CharacterBase, delta: float) -> void:
	pass
