extends Control

# Settings menu scene
var settings_menu_scene = preload("res://src/scenes/menus/settings_menu.tscn")
var settings_menu_instance = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	AudioPlayer.play_music("menu", -2.0) # volume in db


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_game_pressed() -> void:
	AudioPlayer.stop()
	GameManager.load_level(1) # Index 0 is test level


func _on_select_level_pressed() -> void:
	get_tree().change_scene_to_file("res://src/scenes/menus/level_selector_menu.tscn")


func _on_quit_game_pressed() -> void:
	get_tree().quit()


func _on_settings_pressed() -> void:
	# Instantiate and overlay settings menu instead of changing scenes
	if settings_menu_instance == null:
		# Hide the main menu but don't free it
		visible = false

		# Add settings menu to the parent so it doesn't get freed with main menu
		settings_menu_instance = settings_menu_scene.instantiate()
		settings_menu_instance.process_mode = Node.PROCESS_MODE_ALWAYS

		get_parent().add_child(settings_menu_instance)

		# Pass reference to main menu - settings script is on the child Control node
		var settings_control = settings_menu_instance.get_node("SettingsMenu")
		if settings_control != null:
			settings_control.main_menu_ref = self
		# Settings menu overlays on top

func show_main_menu() -> void:
	# Called directly by settings menu when it closes
	visible = true
	settings_menu_instance = null
