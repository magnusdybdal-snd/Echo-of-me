class_name FallPlayerState
extends BasePlayerState

func enter(player: CharacterBase) -> void:
	player.stop_footsteps()
	player.animated_sprite.play("in air")


func exit(player: CharacterBase) -> void:
	pass


func pre_update(player: CharacterBase) -> void:
	if player.is_on_floor():
		player.change_state_to(PlayerStates.LANDING)
		return
	
	if Input.is_action_just_pressed("dash") and not player.has_used_dash:
		player.change_state_to(PlayerStates.DASH)
		return


func update(player: CharacterBase, delta: float) -> void:
	player.velocity += player.get_gravity() * delta
