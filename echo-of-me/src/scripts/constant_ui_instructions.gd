extends Control


@onready var i_keycap: Panel = $HBoxContainer/i_keycap
@onready var e_keycap: Panel = $HBoxContainer/e_keycap
@onready var echo_sprite: TextureRect = $HBoxContainer/EchoSprite
@onready var echo_count_label: Label = $HBoxContainer/EchoCount

var level_controller: Node = null

# Visual feedback constants
const NORMAL_COLOR = Color(1.0, 1.0, 1.0, 1.0)  # White (normal)
const PRESSED_COLOR = Color(0.6, 0.6, 0.6, 1.0)  # Darker gray when pressed


func _ready() -> void:
	# I button should always be visible
	i_keycap.visible = true
	update_echo_display()

	# Set initial colors
	i_keycap.modulate = NORMAL_COLOR
	e_keycap.modulate = NORMAL_COLOR


func _process(delta: float) -> void:
	update_echo_display()
	update_key_visuals()


func update_key_visuals() -> void:
	# Update I key visual feedback
	if Input.is_key_pressed(KEY_I):
		i_keycap.modulate = PRESSED_COLOR
	else:
		i_keycap.modulate = NORMAL_COLOR

	# Update E key visual feedback (only if echoes are enabled)
	if GameManager.can_use_echoes():
		if Input.is_action_pressed("soft_reset"):  # E key
			e_keycap.modulate = PRESSED_COLOR
		else:
			e_keycap.modulate = NORMAL_COLOR


func update_echo_display() -> void:
	# Check if echoes are enabled in this level
	var can_use_echoes = GameManager.can_use_echoes()

	# Show/hide E keycap, echo sprite, and label based on whether echoes are enabled
	e_keycap.visible = can_use_echoes
	echo_sprite.visible = can_use_echoes
	echo_count_label.visible = can_use_echoes

	if can_use_echoes:
		# Get the level controller to check current echo count
		if level_controller == null:
			level_controller = get_tree().current_scene.get_node_or_null("LevelController")

		if level_controller != null:
			var current_echoes = level_controller.echoes.size()
			var max_echoes = GameManager.max_echoes
			echo_count_label.text = str(current_echoes) + "/" + str(max_echoes)
		else:
			# Fallback if level controller not found
			var max_echoes = GameManager.max_echoes
			echo_count_label.text = "0/" + str(max_echoes)
