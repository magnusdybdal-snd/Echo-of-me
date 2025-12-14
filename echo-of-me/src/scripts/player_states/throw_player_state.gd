class_name ThrowPlayerState
extends BasePlayerState

func enter(player: CharacterBase) -> void:
	player.carried_box.throw_box(player.facing_direction, player.velocity)
	player.animated_sprite.play("throw")
	player.pick_up_target = null
	player.carried_box = null


func exit(player: CharacterBase) -> void:
	pass


func pre_update(player: CharacterBase) -> void:
	if not player.animated_sprite.is_playing():
		player.change_state_to(PlayerStates.IDLE)


func update(player: CharacterBase, delta: float) -> void:
	player.velocity += player.get_gravity() * delta
