class_name PlaceDownPlayerState
extends BasePlayerState

func enter(player: CharacterBase) -> void:
	player.carried_box.place_down(player.facing_direction)
	player.animated_sprite.play("place_down")


func exit(player: CharacterBase) -> void:
	player.pick_up_target = null
	player.carried_box = null


func pre_update(player: CharacterBase) -> void:
	if not player.animated_sprite.is_playing():
		player.change_state_to(PlayerStates.IDLE)


func update(player: CharacterBase, delta: float) -> void:
	player.velocity += player.get_gravity() * delta
