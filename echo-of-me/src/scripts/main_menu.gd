extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_game_pressed() -> void:
	GameManager.load_level(1) # Index 0 is test level


func _on_select_level_pressed() -> void:
	get_tree().change_scene_to_file("res://src/scenes/menus/level_selector_menu.tscn")


func _on_quit_game_pressed() -> void:
	get_tree().quit()
