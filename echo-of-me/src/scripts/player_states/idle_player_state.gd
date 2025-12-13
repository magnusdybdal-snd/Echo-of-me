class_name IdlePlayerState
extends BasePlayerState

var nearest_box : RigidBody2D = null

func enter(player: CharacterBase) -> void:
	player.animated_sprite.play("idle")
	player.stop_footsteps()

func exit(player: CharacterBase) -> void:
	pass

## Handles transition rules between states
func pre_update(player: CharacterBase) -> void:
	var direction = player.get_direction()
	
	# If we are not on the floor and we are falling downwards
	if not player.is_on_floor() and player.velocity.y < 0:
		player.change_state_to(PlayerStates.FALL)
		return
		
	# Jump
	if Input.is_action_just_pressed("jump"):
		player.change_state_to(PlayerStates.JUMP)
		
	# Pick up box
	if Input.is_action_just_pressed("pick_up") and player:
		player.pick_up_target = player.find_nearest_box()
		if player.pick_up_target != null and player.pick_up_target.has_method("pick_up"):
			player.change_state_to(PlayerStates.PICK_UP)
		return
		
		
	# Determine if we are running or walking
	if direction != 0 and player.is_on_floor():
		player.change_state_to(PlayerStates.WALK)


func update(player: CharacterBase, delta: float) -> void:
	player.velocity += player.get_gravity() * delta
