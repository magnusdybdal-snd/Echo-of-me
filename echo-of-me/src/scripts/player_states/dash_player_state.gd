class_name DashPlayerState
extends BasePlayerState

const DASH_FORCE := 300.0 # Horizontal velocity applied when dashing
const DASH_DURATION := 0.2 # How long the dash lasts in seconds

var dash_timer := 0.0

func enter(player: CharacterBase) -> void:
	dash_timer = 0.0
	player.animated_sprite.play("dash")
	AudioPlayer.play_sfx("dash")
	player.velocity.x += DASH_FORCE * player.facing_direction
	player.velocity.y = 0
	player.has_used_dash = true
	

func exit(_player: CharacterBase) -> void:
	pass


func pre_update(player: CharacterBase) -> void:
	if not player.animated_sprite.is_playing():
		player.change_state_to(PlayerStates.FALL)


func update(player: CharacterBase, delta: float) -> void:
	dash_timer += delta
	
	if dash_timer < DASH_DURATION:
		player.velocity.y = 0
	else:
		player.velocity += player.get_gravity() * delta
