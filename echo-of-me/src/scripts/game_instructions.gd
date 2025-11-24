extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_instructions()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().paused = false

func update_instructions() -> void:
	# Get references to labels
	var run_label = $"Overlay Box/HBoxContainer/Run"
	var echo_label = $"Overlay Box/HBoxContainer/Echo"
	var reset_label = $"Overlay Box/HBoxContainer/Reset"
	var dash_label = $"Overlay Box/HBoxContainer/Dash"

	# Show/hide based on GameManager state
	run_label.visible = GameManager.has_powerup("sprint")
	echo_label.visible = GameManager.can_use_echoes()
	reset_label.visible = GameManager.can_use_echoes()
	dash_label.visible = GameManager.has_powerup("dash")
	
