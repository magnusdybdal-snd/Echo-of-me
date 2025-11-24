extends Control


@onready var i_keycap: Panel = $HBoxContainer/i_keycap
@onready var e_keycap: Panel = $HBoxContainer/e_keycap
@onready var echo_sprite: TextureRect = $HBoxContainer/EchoSprite
@onready var echo_count_label: Label = $HBoxContainer/EchoCount

var level_controller: Node = null


func _ready() -> void:
	# I button should always be visible
	i_keycap.visible = true
	update_echo_display()


func _process(delta: float) -> void:
	update_echo_display()


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
