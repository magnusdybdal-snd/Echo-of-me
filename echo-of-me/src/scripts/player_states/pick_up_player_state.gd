class_name PickUpPlayerState
extends BasePlayerState

func enter(player: CharacterBase) -> void:
	# Use cached target if available, otherwise find nearest
	var target_box = player.pick_up_target if player.pick_up_target != null else player.find_nearest_box()

	if target_box != null and target_box.has_method("pick_up"):
		target_box.pick_up(player)
		player.carried_box = target_box
		player.animated_sprite.play("idle_carry_box")
	else:
		# No box to pick up, abort to idle
		player.change_state_to(PlayerStates.IDLE)
		return

	# Clear cached target
	player.pick_up_target = null

func exit(player: CharacterBase) -> void:
	pass


func pre_update(player: CharacterBase) -> void:
	player.change_state_to(PlayerStates.IDLE_CARRY)


func update(player: CharacterBase, delta: float) -> void:
	pass
