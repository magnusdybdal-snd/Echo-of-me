extends Control


@onready var vol_slider: HSlider = $MenuButtons/Volume/HBoxContainer/vol_slider
@onready var vol_num_value: Label = $MenuButtons/Volume/HBoxContainer/vol_num_value

# References to menus (set by pause_menu.gd or main_menu.gd)
var pause_menu_ref = null
var main_menu_ref = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set up the volume slider
	vol_slider.min_value = 0
	vol_slider.max_value = 100
	vol_slider.value = 100
	vol_slider.step = 1

	# Connect slider signal to update label
	vol_slider.value_changed.connect(_on_vol_slider_value_changed)

	# Initialize the label
	_on_vol_slider_value_changed(vol_slider.value)


func _on_vol_slider_value_changed(value: float) -> void:
	# Update the percentage label to match slider value
	vol_num_value.text = str(int(value)) + " %"


func _on_back_pressed() -> void:
	AudioPlayer.play_sfx("click")
	# Remove the settings menu overlay and show the previous menu
	# Check which menu we came from and show it
	if pause_menu_ref != null:
		pause_menu_ref.show_pause_menu()
	elif main_menu_ref != null:
		main_menu_ref.show_main_menu()

	queue_free()
	
