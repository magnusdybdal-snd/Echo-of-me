extends Node2D

@onready var animation_player: AnimationPlayer = $LevelController/AnimationPlayer
@onready var _dialog: Control = $LevelController/UI/Dialog

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_dialog.display_line("Hello World")
	animation_player.play("cutscene")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
 
