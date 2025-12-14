class_name LandingPlayerState
extends BasePlayerState

const SPEED := 150.0
const RUN_SPEED := 210.0

func enter(player: CharacterBase) -> void:
	player.animated_sprite.play("landing")
	AudioPlayer.play_sfx("landing")

func exit(player: CharacterBase) -> void:
	player.has_used_dash = false


func pre_update(player: CharacterBase) -> void:
	if Input.is_action_pressed("sprint"):
		player.target_speed = RUN_SPEED
	else:
		player.target_speed = SPEED
	
	if Input.is_action_just_pressed("jump"):
		player.change_state_to(PlayerStates.JUMP)
	if not player.animated_sprite.is_playing():
		var direction = player.get_direction()
		if direction == 0:
			player.change_state_to(PlayerStates.IDLE)
		elif Input.is_action_pressed("sprint") and player.can_sprint:
			player.change_state_to(PlayerStates.RUN)
		else:
			player.change_state_to(PlayerStates.WALK)


func update(player: CharacterBase, delta: float) -> void:
	player.velocity += player.get_gravity() * delta
