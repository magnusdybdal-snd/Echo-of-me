class_name WallSlidePlayerState
extends BasePlayerState

func enter(player: CharacterBase) -> void:
	player.animated_sprite.play("wall_slide")


func exit(player: CharacterBase) -> void:
	pass


func pre_update(player: CharacterBase) -> void:
	pass


func update(player: CharacterBase, delta: float) -> void:
	pass
