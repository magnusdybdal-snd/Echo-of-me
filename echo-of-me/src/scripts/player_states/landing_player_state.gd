class_name LandingPlayerState
extends BasePlayerState

func enter(player: CharacterBase) -> void:
	player.animated_sprite.play("landing")
	AudioPlayer.play_sfx("landing")

func exit(player: CharacterBase) -> void:
	player.has_used_dash = false


func pre_update(player: CharacterBase) -> void:
	if not player.animated_sprite.is_playing():
		player.change_state_to(PlayerStates.IDLE)


func update(player: CharacterBase, delta: float) -> void:
	player.velocity += player.get_gravity() * delta
