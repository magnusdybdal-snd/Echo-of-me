# level_transition.gd
extends CanvasLayer
# Handles smooth fade transitions between levels

@onready var panel: Panel = $Panel
@onready var label: Label = $Panel/Level_name # label to display name og level

# Transition durations
const FADE_IN_DURATION = 0.7   # Time to fade to black
const WAIT_TIMER = 2.0		   # Time between fades
const FADE_OUT_DURATION = 0.7  # Time to fade from black

func _ready():
	# Start fully transparent (invisible)clas
	panel.modulate.a = 0.0
	# Always process even when game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

# Fade to black, load scene, then fade from black
func transition_to_scene(scene_path: String) -> void:
	# Fade in (to black)
	print("current index start: ", GameManager.current_level_index)
	await fade_in()
	
	# Display name of scene as label
	label.text = GameManager.levels[GameManager.current_level_index].name # Display name of level being loaded
	
	# Waits 0.5s before fading in.
	await get_tree().create_timer(WAIT_TIMER).timeout
	# Load the new scene
	var error = get_tree().change_scene_to_file(scene_path)
	if error != OK:
		push_error("Failed to load scene: " + scene_path)
		return
	
	# Wait one frame to ensure new scene is ready
	await get_tree().process_frame
	
	label.text = "" # Remove labelname before fadeout (text dont fade with panel)

	# Fade out (from black)
	print("current index after: ", GameManager.current_level_index)
	await fade_out()

# Fades the screen to black
func fade_in() -> void:
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(panel, "modulate:a", 1.0, FADE_IN_DURATION)
	await tween.finished

# Fades the screen from black to transparent
func fade_out() -> void:
	var tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(panel, "modulate:a", 0.0, FADE_OUT_DURATION)
	await tween.finished
