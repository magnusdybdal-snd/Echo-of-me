# GameManager.gd
extends Node
# (autoloaded in Project Settings → AutoLoad)

# put global settings here later if you want
# e.g. audio volume, keybindings, unlocked levels

func _ready() -> void:
	# This runs once, when the project starts
	print("GameManager loaded")

# Level manager
var levels := [
	"res://src/scenes/levels/test_level.tscn",
	"res://src/scenes/levels/level_01.tscn", 
	"res://src/scenes/levels/level_02.tscn",
	"res://src/scenes/levels/level_03.tscn",
	"res://src/scenes/levels/level_04.tscn",
	"res://src/scenes/levels/level_05.tscn",
]
var current_level_index := 0

# Powerups state manager
var unlocked_powerups := {
	"sprint": false,
	"echo": false,
	"double_echo": false,
	"unlimited_echo": false,
	"wall_climp": false,
	"double_jump": false,
	"dash": false
}

# Level loading
func load_current() -> void:
	check_level_powerups()	# Check powerups to use in level
	get_tree().change_scene_to_file(levels[current_level_index])

func load_next() -> void:
	current_level_index += 1
	if current_level_index < levels.size():
		check_level_powerups()
		var error = get_tree().change_scene_to_file(levels[current_level_index])
		if error == OK:		
			print(get_tree().change_scene_to_file(levels[current_level_index]))
			print("Loaded level: " + levels[current_level_index])
		else:
			print("ERROR loading level " + str(error))
	else:
		print("Out of levels — Hurray you won?")
		
# Auto unlocks powerups based on level progression
func check_level_powerups() -> void:
	# Unlock sprinting at level 2
	if current_level_index >= 2:
		unlock_powerup("sprint")
		unlock_powerup("echo")
		
# Function to unlock powerups
func unlock_powerup(powerup_name: String) -> void:
	if powerup_name in unlocked_powerups:
		if not unlocked_powerups[powerup_name]:
			print("Unlocked powerup: " + powerup_name)
		unlocked_powerups[powerup_name] = true
	else:
		print("Warning: Unknown powerup: " + powerup_name)

# Function to lock powerups
func lock_powerup(powerup_name: String) -> void:
	if powerup_name in unlocked_powerups:
		unlocked_powerups[powerup_name] = true
		print("Locked powerup: " + powerup_name)
	else:
		print("Warning: Unknow powerup: " + powerup_name)
	
func has_powerup(powerup_name: String) -> bool:
	return unlocked_powerups.get(powerup_name, false)
	
func reset_powerups() -> void:
	for key in unlocked_powerups.keys():
		unlocked_powerups[key] = false
	print("Reset all powerups")
	
func unlock_all_powerups() -> void:
	for key in unlocked_powerups.keys():
		unlocked_powerups[key] = true
	print("Unlcoked all powerups")
