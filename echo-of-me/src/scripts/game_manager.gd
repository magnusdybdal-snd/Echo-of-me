# GameManager.gd
extends Node
# (autoloaded in Project Settings → AutoLoad)

# put global settings here later if you want
# e.g. audio volume, keybindings, unlocked levels

# Level manager with metadata
var levels := [
	{
		"name": "Test Level (Dev)",
		"scene": "res://src/scenes/levels/test_level.tscn",
		"is_test": true,
		"max_echoes": 999,
		"available_powerups": ["sprint", "wall_climb", "double_jump", "dash"]  
	},
	{
		"name": "Level 1 - First Steps",
		"scene": "res://src/scenes/levels/level_01.tscn",
		"max_echoes": 0,
		"available_powerups": []
	},
	{
		"name": "Level 2 - Sprint Tutorial",
		"scene": "res://src/scenes/levels/level_02.tscn",
		"max_echoes": 0,
		"available_powerups": ["sprint"]
	},
	{
		"name": "Level 3 - Key",
		"scene": "res://src/scenes/levels/level_03.tscn",
		"max_echoes": 0,
		"available_powerups": ["sprint"]
	},
	{
		"name": "Level 4 - Box Intro",
		"scene": "res://src/scenes/levels/level_04.tscn",
		"max_echoes": 0,
		"available_powerups": ["sprint"]
	},
	{
		"name": "Level 5 - Platforms",
		"scene": "res://src/scenes/levels/level_05.tscn",
		"max_echoes": 0,
		"available_powerups": ["sprint"]
	},
]

var current_level_index := 1 # 0 is test level

# Powerups state manager
var max_echoes := 0
var unlocked_powerups := {
	"sprint": false,
	"wall_climb": false,
	"double_jump": false,
	"dash": false
}

func _ready() -> void:
	pass

# Level loading
func load_level(level_index: int) -> void:
	if level_index >= 0 and level_index < levels.size():
		current_level_index = level_index
		check_level_powerups()
		var level_data = levels[level_index]
		var error = get_tree().change_scene_to_file(level_data["scene"])
		if error != OK:
			print("ERROR: Invalid level index " + str(level_index))
	else:
		print("Out of levels - Hurray you won?")

func load_next() -> void:
	load_level(current_level_index + 1)
		
# Auto unlocks powerups based on level progression
# TODO: Levels are currently just for testing
func check_level_powerups() -> void:
	print("DEBUG: current level index: " + str(current_level_index))
	
	var level_data = levels[current_level_index]
	
	reset_powerups()
	max_echoes = level_data["max_echoes"]
	for powerup in level_data["available_powerups"]:
		unlock_powerup(powerup)
			
	# Debug output
	print("DEBUG: Level name: " + level_data["name"])
	print("DEBUG: Max echoes = " + str(max_echoes))
	print("DEBUG: Can use echoes = " + str(can_use_echoes()))
	print("DEBUG: Powerup status:")
	for powerup_name in unlocked_powerups:
		var status = "✓" if unlocked_powerups[powerup_name] else "✗"
		print("  " + status + " " + powerup_name)
			
# Check if player can use echoes
func can_use_echoes() -> bool:
		return max_echoes > 0

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
		unlocked_powerups[powerup_name] = false
		print("Locked powerup: " + powerup_name)
	else:
		print("Warning: Unknow powerup: " + powerup_name)
	
func has_powerup(powerup_name: String) -> bool:
	return unlocked_powerups.get(powerup_name, false)
	
func reset_powerups() -> void:
	for key in unlocked_powerups.keys():
		unlocked_powerups[key] = false
	print("Reset all powerups")
