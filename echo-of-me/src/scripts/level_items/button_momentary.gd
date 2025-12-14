extends Area2D

@export var is_pressed_moment: bool = false

signal pressed
signal released

var is_resetting: bool = false

func _ready():
	$AnimatedSprite2D.play("released")
	var level_controller = get_tree().current_scene.get_node("LevelController")
	level_controller.connect("reset_level", Callable(self, "_on_reset_level"))

func _on_reset_level():
	is_resetting = true
	is_pressed_moment = false
	$AnimatedSprite2D.play("released")

	# Clear the flag after physics has settled
	await get_tree().physics_frame
	await get_tree().physics_frame
	is_resetting = false

func _on_body_entered(_body: Node2D) -> void:
	if not is_pressed_moment:
		is_pressed_moment = true
		$AnimatedSprite2D.play("pressed")
		emit_signal("pressed")


func _on_body_exited(_body: Node2D) -> void:
	# Don't emit released signal if exit was caused by a reset
	if is_pressed_moment and not is_resetting:
		is_pressed_moment = false
		$AnimatedSprite2D.play("released")
		emit_signal("released")
