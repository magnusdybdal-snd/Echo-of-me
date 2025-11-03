# GameManager.gd
extends Node
# (autoloaded in Project Settings → AutoLoad)

# put global settings here later if you want
# e.g. audio volume, keybindings, unlocked levels

func _ready() -> void:
	# This runs once, when the project starts
	print("GameManager loaded")

var levels := [
	"res://src/scenes/levels/test_level.tscn",
	"res://src/scenes/levels/level_01.tscn",
	"res://src/scenes/levels/level_02.tscn",
	"res://src/scenes/levels/level_03.tscn",
	"res://src/scenes/levels/level_04.tscn",
	"res://src/scenes/levels/level_05.tscn",
]

var index := 0

func load_current() -> void:
	get_tree().change_scene_to_file(levels[index])
	print(get_tree().change_scene_to_file(levels[index]))

func load_next() -> void:
	index += 1
	if index < levels.size():
		get_tree().change_scene_to_file(levels[index])
	else:
		print("Out of levels — Hurray you won?")
