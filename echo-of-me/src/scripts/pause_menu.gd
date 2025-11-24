extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().paused = false


func _on_continue_game_pressed() -> void:
	get_tree().paused = false
	queue_free() 

func _on_select_level_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://src/scenes/menus/level_selector_menu.tscn")

func _on_settings_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://src/scenes/menus/settings_menu.tscn")

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://src/scenes/menus/main_menu.tscn")
