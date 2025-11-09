extends Node

signal reset_level

@export var player_path : NodePath
# Gets the player from the level it is controllingplayer_path
@onready var player = get_node("Player")

var echoes : Array = []
var can_spawn_echoes = GameManager.can_use_echoes()

func _input(event):
	if player.is_dead:
		return

	if event.is_action_pressed("soft_reset") and GameManager.can_use_echoes(): # E for echo spawn
		soft_reset()
	elif event.is_action_pressed("hard_reset") and GameManager.can_use_echoes(): # R for reset level and echos
		hard_reset()
		
# Resets the player position to spawn and spawns an echo based on the players inputs
# Then resets the recording of the player for new recording
func soft_reset():
	if player.recording.size() > 0:
		# If echo is at max limit, replace oldest echo
		if echoes.size() >= GameManager.max_echoes:
			remove_oldest_echo()
			print("Echo spawn limitation reached: " + str(GameManager.max_echoes))
		# Spawns new echo
		spawn_echo_from_player()
		# Reset all echoes to original position
		reset_all_echoes()
		
	reset_level_state()
	start_new_recording()
	
# Remove the oldest (first) echo
func remove_oldest_echo() -> void:
	if echoes.size() > 0:
		var oldest_echo = echoes[0]
		oldest_echo.queue_free()
		echoes.remove_at(0)
		print("Replaced oldest echo")
		
# Reset all echoes to recording frame 0 and spawn position
func reset_all_echoes():
	for echo in echoes:
		if is_instance_valid(echo):
			echo.reset_playback()
			
# Resets the level, removes echoes and clears all recordings, like starting the level fresh
func hard_reset():
	reset_level_state()
	clear_echoes()
	start_new_recording()
	
	# Revive player
	if player is CharacterBase:
		player.revive()
	else:	# Fallback unfreeze
		ensure_unfreeze()			
		if player.has_node("AnimatedSprite2D"):
			player.get_node("AnimatedSprite2D").play()
	
	# Reset velocity completely
	player.velocity = Vector2.ZERO
	
# Instantiates an echo scene and adds an echo with the players position and recordings
func spawn_echo_from_player():
	var echo_scene = preload("res://src/scenes/echo_player.tscn")
	var echo = echo_scene.instantiate()
	
	echo.spawn_position = player.spawn_position
	echo.global_position = player.spawn_position
	echo.recorded_inputs = player.recording.duplicate(true)
	
	add_child(echo)
	echoes.append(echo) 	

# Clears all echoes for hard reset
func clear_echoes():
	for e in echoes:
		if is_instance_valid(e):
			e.queue_free()
	echoes.clear()
	
func reset_level_state():
	# All objects to be reset should listen to this signal
	emit_signal("reset_level")
	
# Clear all recorded moves from the player
func start_new_recording():
	player.recording.clear()
	player.frame_index = 0
	player.is_recording = GameManager.can_use_echoes()

func ensure_unfreeze():
	# Unfreeze player
	player.set_process_input(true)
	player.set_process(true)
	player.set_physics_process(true)
	
	# Reset velocity completely
	player.velocity = Vector2.ZERO
