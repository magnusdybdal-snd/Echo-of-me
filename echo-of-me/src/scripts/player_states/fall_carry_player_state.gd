class_name FallCarryPlayerState
extends BasePlayerState

func enter(player: CharacterBase) -> void:
	player.stop_footsteps()
	player.animated_sprite.play("in_air_carry_box")


func exit(player: CharacterBase) -> void:
	pass


func pre_update(player: CharacterBase) -> void:
	pass


func update(player: CharacterBase, delta: float) -> void:
	pass
