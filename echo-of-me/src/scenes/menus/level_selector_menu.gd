extends Control

func _ready():
	_connect_level_buttons()

func _connect_level_buttons() -> void:
	for container in $VBoxContainer.get_children():
		if container is HBoxContainer:
			for button in container.get_children():
				if button is Button:
					button.pressed.connect(_on_level_button_pressed.bind(button))

func _on_level_button_pressed(button: Button) -> void:
	var level_path: String
	
	if button.name == "test_level": # check if test level
		level_path = "res://src/scenes/levels/test_level.tscn"
	else:
		var level_number = button.name  # Keep as string to preserve leading zeros
		level_path = "res://src/scenes/levels/level_%s.tscn" % level_number
		
	print("Loading level: ", button.name)
	get_tree().change_scene_to_file(level_path)
