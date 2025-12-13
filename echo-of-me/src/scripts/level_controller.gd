extends Node

signal reset_level

@export var player_path : NodePath
# Gets the player from the level it is controllingplayer_path
@onready var player = get_node("Player")

# Pause menu scene
var pause_menu_scene = preload("res://src/scenes/menus/pause_menu.tscn")
var pause_menu_instance = null

# Death screen 
var death_screen_scene = preload("res://src/scenes/deathscreen.tscn")
var death_screen_instance = null

# Control menu info
var control_menu_info = preload("res://src/scenes/UI/GameInstructions.tscn")
var control_menu_instance = null
var control_menu_show = false


var echoes : Array = []
var can_spawn_echoes = GameManager.can_use_echoes()

func _ready():
	# Allow level controller to process input even when game is paused
	# (needed for pause menu toggle and death screen reset)
	process_mode = Node.PROCESS_MODE_ALWAYS

	# Ensure player pauses normally despite parent's PROCESS_MODE_ALWAYS
	player.process_mode = Node.PROCESS_MODE_PAUSABLE

func _process(_delta):
	# Show death screen immediately when player dies
	if player.is_dead and death_screen_instance == null:
		AudioPlayer.play_sfx("death_sound", -3.0)
		death_screen_instance = death_screen_scene.instantiate()
		death_screen_instance.process_mode = Node.PROCESS_MODE_ALWAYS
		add_child(death_screen_instance)
		get_tree().paused = true
		

		# Fade in the death screen elements
		var panel = death_screen_instance.get_node("PanelContainer")
		var vbox = death_screen_instance.get_node("VBoxContainer")

		# Start invisible
		panel.modulate.a = 0.0
		vbox.modulate.a = 0.0

		# Fade in over 0.5 seconds
		var tween = create_tween()
		tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)  # Allow tween during pause
		tween.tween_property(panel, "modulate:a", 1.0, 0.5)
		tween.parallel().tween_property(vbox, "modulate:a", 1.0, 0.5)

func _input(event):
	# Handle reset from death screen
	if player.is_dead and event.is_action_pressed("hard_reset"):
		hard_reset()
		# Clean up death screen
		if death_screen_instance != null:
			get_tree().paused = false
			death_screen_instance.queue_free()
			death_screen_instance = null
		return

	# Normal gameplay inputs (only when alive and not paused)
	if pause_menu_instance == null and not player.is_dead:  # Don't allow resets while pause menu or death screen is open
		if event.is_action_pressed("soft_reset") and GameManager.can_use_echoes(): # E for echo spawn
			soft_reset()
		elif event.is_action_pressed("hard_reset") and GameManager.can_use_echoes(): # R for reset level and echos
			hard_reset()
	
	if event.is_action_pressed("ui_cancel"):
		if pause_menu_instance == null:
			# Create and show menu
			pause_menu_instance = pause_menu_scene.instantiate()
			pause_menu_instance.process_mode = Node.PROCESS_MODE_ALWAYS
			add_child(pause_menu_instance)
			
			var animationPlayers = get_tree().get_nodes_in_group("AnimationPlayer")
			for anim_player in animationPlayers:
				anim_player.speed_scale = 0
				
			get_tree().paused = true
		else:
			# Hide and remove menu
			var animationPlayers = get_tree().get_nodes_in_group("AnimationPlayer")
			for anim_player in animationPlayers:
				anim_player.speed_scale = 1
			get_tree().paused = false
			pause_menu_instance.queue_free()
			pause_menu_instance = null
	
	if event is InputEventKey and event.pressed and event.keycode == KEY_I:
		if control_menu_instance == null:
			# Create and show instructions menu
			control_menu_instance = control_menu_info.instantiate()
			add_child(control_menu_instance)
			control_menu_show = true
		else:
			# Hide and remove instructions menu
			control_menu_instance.queue_free()
			control_menu_instance = null
			control_menu_show = false
		
	
		
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

	# Ensure echo pauses normally despite parent's PROCESS_MODE_ALWAYS
	echo.process_mode = Node.PROCESS_MODE_PAUSABLE

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
	
