class_name LandingPlayerState
extends BasePlayerState

const SPEED := 150.0
const RUN_SPEED := 210.0

func enter(player: CharacterBase) -> void:
	AudioPlayer.play_sfx("landing")
	player.animated_sprite.play("landing")
	# Reset the dash and double jump flag when we land
	player.has_used_dash = false
	player.used_double_jump = false
	player.cyote_time_remaining = player.CYOTEE_GRACE_TIME

func exit(_player: CharacterBase) -> void:
	pass

func pre_update(player: CharacterBase) -> void:
	# Set speed based on if we are running or walking, but continue playing
	# landing animation
	if player.is_action_pressed_virtual("sprint") and player.can_sprint:
		player.target_speed = RUN_SPEED
	else:
		player.target_speed = SPEED
	
	# Allow for immidiate jumping after landing, before animation finish
	if player.is_action_just_pressed_virtual("jump"):
		player.change_state_to(PlayerStates.JUMP)

	# Go back to Idle/run/walk based on direction and if player holds shift
	# after animation is finished
	if not player.animated_sprite.is_playing():
		var direction = player.get_direction()
		if direction == 0:
			player.change_state_to(PlayerStates.IDLE)
		elif player.is_action_pressed_virtual("sprint") and player.can_sprint:
			player.change_state_to(PlayerStates.RUN)
		else:
			player.change_state_to(PlayerStates.WALK)

	# Start coyote time when leaving ground, only fall when it expires
	if not player.is_on_floor():
		if player.cyote_time_remaining <= 0 and player.velocity.y > 0:
			player.change_state_to(PlayerStates.FALL)


func update(player: CharacterBase, delta: float) -> void:
	player.velocity += player.get_gravity() * delta

	# Count down coyote time when not on floor
	if not player.is_on_floor():
		if player.cyote_time_remaining > 0:
			player.cyote_time_remaining -= delta
	else:
		# Reset coyote time when on floor
		player.cyote_time_remaining = player.CYOTEE_GRACE_TIME
