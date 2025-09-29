extends Node
signal reset_level

@export var player_path : NodePath
# Gets the player from the level it is controlling
@onready var player = get_node(player_path)

var echoes : Array = []

func _input(event):
	if event.is_action_pressed("soft_reset"): # E for echo spawn
		soft_reset()
	elif event.is_action_pressed("hard_reset"): # R for reset level and echos
		hard_reset()
		
# Resets the player position to spawn and spawns an echo based on the players inputs
func soft_reset():
	#reset_player()
	reset_level_state()
	#spawn_echo_from_player()
	#start_new_recording()
	
# Resets the level, removes echoes and clears all recordings, like starting the level fresh
func hard_reset():
	reset_player()
	reset_level_state()
	clear_echoes()
	start_new_recording()
	
# Instantiates an echo scene and adds an echo with the players position and recordings
func spawn_echo_from_player():
	var echo_scene = preload("res://src/scenes/echo_player.tscn")
	var echo = echo_scene.instantiate()
	echo.global_position = player.global_position
	echo.recorded_inputs = player.recording.duplicate(true)
	get_parent().add_child(echo)
	echoes.append(echo) 	

# Clears all echoes for hard reset
func clear_echoes():
	for e in echoes:
		e.queue_free()
	echoes.clear()
	
func reset_level_state():
	# All objects to be reset should listen to this signal
	emit_signal("reset_level")
	
# Resets the player position to the spawn of the level
func reset_player():
	player.global_position = player.spawn_position
	player.velocity = Vector2.ZERO
	
# Clear all recorded moves from the player
func start_new_recording():
	player.recording.clear()
