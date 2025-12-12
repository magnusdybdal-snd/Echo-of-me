extends Control


# Settings menu scene
var settings_menu_scene = preload("res://src/scenes/menus/settings_menu.tscn")
var settings_menu_instance = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _input(event):
	# Only handle ESC if pause menu is visible (not hidden by settings menu)
	if event.is_action_pressed("ui_cancel") and visible:
		get_tree().paused = false


func _on_continue_game_pressed() -> void:
	AudioPlayer.play_sfx("click")
	get_tree().paused = false
	queue_free()

func _on_select_level_pressed() -> void:
	AudioPlayer.play_sfx("click")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://src/scenes/menus/level_selector_menu.tscn")

func _on_settings_pressed() -> void:
	AudioPlayer.play_sfx("click")
	# Instantiate and overlay settings menu instead of changing scenes
	if settings_menu_instance == null:
		# Hide the pause menu but don't free it
		visible = false

		# Add settings menu to the parent (LevelController) so it doesn't get freed with pause menu
		settings_menu_instance = settings_menu_scene.instantiate()
		settings_menu_instance.process_mode = Node.PROCESS_MODE_ALWAYS

		get_parent().add_child(settings_menu_instance)

		# Pass reference to pause menu - settings script is on the child Control node
		var settings_control = settings_menu_instance.get_node("SettingsMenu")
		if settings_control != null:
			settings_control.pause_menu_ref = self
		# Game stays paused, settings menu overlays on top

func show_pause_menu() -> void:
	# Called directly by settings menu when it closes
	visible = true
	settings_menu_instance = null

func _on_main_menu_pressed() -> void:
	AudioPlayer.play_sfx("click")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://src/scenes/menus/main_menu.tscn")
