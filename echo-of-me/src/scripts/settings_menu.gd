extends Control


@onready var vol_slider: HSlider = $"MenuButtons/Volume/VolumeSliderBox/vol_slider"
@onready var vol_num_value: Label = $"MenuButtons/Volume/VolumeSliderBox/vol_num_value"

# References to menus (set by pause_menu.gd or main_menu.gd)
var pause_menu_ref = null
var main_menu_ref = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set up the volume slider
	vol_slider.min_value = 0
	vol_slider.max_value = 100
	vol_slider.step = 1

	# Load current master volume and set slider to match
	var master_bus_idx = AudioServer.get_bus_index("Master")
	var current_volume_db = AudioServer.get_bus_volume_db(master_bus_idx)
	var current_volume_linear = db_to_linear(current_volume_db)
	vol_slider.value = current_volume_linear * 100

	# Connect slider signal to update label and volume
	vol_slider.value_changed.connect(_on_vol_slider_value_changed)

	# Initialize the label
	_on_vol_slider_value_changed(vol_slider.value)


func _on_vol_slider_value_changed(value: float) -> void:
	# Update the percentage label to match slider value
	vol_num_value.text = str(int(value)) + " %"

	# Convert linear slider value (0-100) to audio bus volume in decibels
	var volume_linear = value / 100.0
	var volume_db = linear_to_db(volume_linear)

	# Set the master bus volume
	var master_bus_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_bus_idx, volume_db)


func _on_back_pressed() -> void:
	AudioPlayer.play_sfx("click")
	# Remove the settings menu overlay and show the previous menu
	# Check which menu we came from and show it
	if pause_menu_ref != null:
		pause_menu_ref.show_pause_menu()
	elif main_menu_ref != null:
		main_menu_ref.show_main_menu()

	queue_free()
	
