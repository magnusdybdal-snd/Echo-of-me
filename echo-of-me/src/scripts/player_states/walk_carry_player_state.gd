class_name WalkCarryPlayerState
extends BasePlayerState

func enter(player: CharacterBase) -> void:
	player.animated_sprite.play("walk_carry_box")
	player.play_footsteps("walk")


func exit(player: CharacterBase) -> void:
	pass


func pre_update(player: CharacterBase) -> void:
	pass


func update(player: CharacterBase, delta: float) -> void:
	pass
