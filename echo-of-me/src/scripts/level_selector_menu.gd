extends Control

func _ready():
	AudioPlayer.play_music("menu", -2.0)
	_connect_level_buttons()
	_validate_level_buttons()

func _connect_level_buttons() -> void:
	for container in $VBoxContainer.get_children():
		if container is HBoxContainer:
			for button in container.get_children():
				if button is Button:
					button.pressed.connect(_on_level_button_pressed.bind(button))

func _on_level_button_pressed(button: Button) -> void:
	var level_index = 0 if button.name == "test_level" else int(button.name) + 1
	GameManager.load_level(level_index)

###--- Check if level exists---###
func _validate_level_buttons() -> void:
	for container in $VBoxContainer.get_children():
		if container is HBoxContainer:
			for button in container.get_children():
				if button is Button:
					var level_index = 0 if button.name == "test_level" else int(button.name)
					
					if level_index >= GameManager.levels.size() - 1:
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
