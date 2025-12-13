extends Control


@onready var vol_slider: HSlider = $"MenuButtons/Volume/VolumeSliderBox/vol_slider"
@onready var vol_num_value: Label = $"MenuButtons/Volume/VolumeSliderBox/vol_num_value"
@onready var mute_button: CheckButton = $"MenuButtons/Volume/Mute/MuteToggle"

# References to menus (set by pause_menu.gd or main_menu.gd)
var pause_menu_ref = null
var main_menu_ref = null

var updating_from_mute_button: bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Set up the volume slider
	vol_slider.min_value = 0
	vol_slider.max_value = 100
	vol_slider.step = 1

	# Load volume from GameManager (persisted state)
	vol_slider.value = GameManager.current_volume

	# Connect slider signal to update label and volume
	vol_slider.value_changed.connect(_on_vol_slider_value_changed)

	# Connect mute button signal
	mute_button.toggled.connect(_on_mute_toggled)

	# Initialize mute button state from GameManager
	mute_button.button_pressed = GameManager.is_muted
	if GameManager.is_muted:
		mute_label.text = "Muted: "
		vol_num_value.text = "Muted"
		# Set slider to 0 visually but don't trigger unmute logic
		updating_from_mute_button = true
		vol_slider.value = 0
		updating_from_mute_button = false
	else:
		mute_label.text = "Mute: "
		# Update the label with current volume
		vol_num_value.text = str(int(GameManager.current_volume)) + " %"

	# Apply the volume to AudioServer
	var volume_linear = GameManager.current_volume / 100.0
	var volume_db = linear_to_db(volume_linear)
	var master_bus_idx = AudioServer.get_bus_index("Master")
	if GameManager.is_muted:
		AudioServer.set_bus_volume_db(master_bus_idx, -80.0)
	else:
		AudioServer.set_bus_volume_db(master_bus_idx, volume_db)


func _on_vol_slider_value_changed(value: float) -> void:
	# If muted and slider is moved manually (not from mute button), unmute
	if GameManager.is_muted and not updating_from_mute_button:
		mute_button.button_pressed = false
<<<<<<< HEAD
		is_muted = false
=======
		GameManager.is_muted = false
		mute_label.text = "Mute: "
>>>>>>> main

	# Save current volume to GameManager
	if not updating_from_mute_button:
		GameManager.current_volume = value

	# Update the percentage label to match slider value
	if not GameManager.is_muted:
		vol_num_value.text = str(int(value)) + " %"

	# Convert linear slider value (0-100) to audio bus volume in decibels
	var volume_linear = value / 100.0
	var volume_db = linear_to_db(volume_linear)

	# Set the master bus volume
	var master_bus_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(master_bus_idx, volume_db)


func _on_mute_toggled(button_pressed: bool) -> void:
	var master_bus_idx = AudioServer.get_bus_index("Master")
	updating_from_mute_button = true

	if button_pressed:
		# Mute: save current volume and set to 0
		GameManager.is_muted = true
		GameManager.saved_volume = vol_slider.value
		vol_slider.value = 0
		vol_num_value.text = "Muted"
		AudioServer.set_bus_volume_db(master_bus_idx, -80.0)  # Effectively silent
	else:
		# Unmute: restore previous volume
<<<<<<< HEAD
		is_muted = false
		vol_slider.value = previous_volume
=======
		GameManager.is_muted = false
		mute_label.text = "Mute: "
		vol_slider.value = GameManager.saved_volume
>>>>>>> main
		# Volume will be set by the slider value_changed signal

	updating_from_mute_button = false


func _on_back_pressed() -> void:
	AudioPlayer.play_sfx("click")
	# Remove the settings menu overlay and show the previous menu
	# Check which menu we came from and show it
	if pause_menu_ref != null:
		pause_menu_ref.show_pause_menu()
	elif main_menu_ref != null:
		main_menu_ref.show_main_menu()

	queue_free()
	
