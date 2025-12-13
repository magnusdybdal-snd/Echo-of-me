class_name LandingCarryPlayerState
extends BasePlayerState

func enter(player: CharacterBase) -> void:
	player.animated_sprite.play("landing_carry_box")
	AudioPlayer.play_sfx("landing")


func exit(player: CharacterBase) -> void:
	pass


func pre_update(player: CharacterBase) -> void:
	pass


func update(player: CharacterBase, delta: float) -> void:
	pass
