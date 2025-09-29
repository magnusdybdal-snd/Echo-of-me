extends Area2D

@export var is_pressed: bool = false

var start_position : Vector2

signal pressed

func _ready():
	$AnimatedSprite2D.play("released")
	var level_controller = get_tree().current_scene.get_node("LevelController")
	level_controller.connect("reset_level", Callable(self, "_on_reset_level"))
	
func _on_body_entered(_body: Node2D) -> void:
	if not is_pressed:
		is_pressed = true
		$AnimatedSprite2D.play("pressed")
		emit_signal("pressed")
		
func _on_reset_level():
	$AnimatedSprite2D.play("released")
	is_pressed = false
