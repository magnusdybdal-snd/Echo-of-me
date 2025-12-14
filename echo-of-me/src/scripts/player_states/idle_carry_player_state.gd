class_name IdleCarryPlayerState
extends BasePlayerState

var direction

func enter(player: CharacterBase) -> void:
	player.animated_sprite.play("idle_carry_box")
	player.stop_footsteps()

func exit(_player: CharacterBase) -> void:
	pass


func pre_update(player: CharacterBase) -> void:
	direction = player.get_direction()
	
	# If we are not on the floor and we are falling downwards
	if not player.is_on_floor() and player.velocity.y < 0:
		player.change_state_to(PlayerStates.FALL_CARRY)
		return
	
	# Jump
	if player.is_action_just_pressed_virtual("jump"):
		player.change_state_to(PlayerStates.JUMP_CARRY)
		
	# Place down or throw based on if we are moving or not
	if player.is_action_just_pressed_virtual("pick_up"):
		if abs(player.velocity.x) < 50:
			player.change_state_to(PlayerStates.PLACE_DOWN)
		else:
			player.change_state_to(PlayerStates.THROW)
	
	if direction != 0 and player.is_on_floor():
		player.change_state_to(PlayerStates.WALK_CARRY)


func update(player: CharacterBase, delta: float) -> void:
	player.velocity += player.get_gravity() * delta
