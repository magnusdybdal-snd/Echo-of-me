extends Control

func _ready():
	_connect_level_buttons()
	_validate_level_buttons()

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

###--- Check if level exists---###
func _validate_level_buttons() -> void:
	for container in $VBoxContainer.get_children():
		if container is HBoxContainer:
			for button in container.get_children():
				if button is Button:
					var level_path = _get_level_path(button.name)
					if not FileAccess.file_exists(level_path):
						# Tint the button red if level doesn't exist
						button.modulate = Color(1.0, 0.5, 0.5)  # Light red tint
						# Optionally disable the button
						button.disabled = true

func _get_level_path(button_name: String) -> String:
	if button_name.is_valid_int():
		return "res://src/scenes/levels/level_%s.tscn" % button_name
	else:
		var safe_name = button_name.replace(" ", "_")
		return "res://src/scenes/levels/%s.tscn" % safe_name
