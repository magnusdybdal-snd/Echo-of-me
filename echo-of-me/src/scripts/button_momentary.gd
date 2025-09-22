extends Area2D

@export var is_pressed: bool = false

signal pressed

func _ready():
	$AnimatedSprite2D.play("released")
	

func _on_body_entered(_body: Node2D) -> void:
	if not is_pressed:
		is_pressed = true
		$AnimatedSprite2D.play("pressed")
		emit_signal("pressed")
		

func _on_body_exited(body: Node2D) -> void:
	if is_pressed:
		is_pressed = false
		$AnimatedSprite2D.play("released")
		emit_signal("released")
