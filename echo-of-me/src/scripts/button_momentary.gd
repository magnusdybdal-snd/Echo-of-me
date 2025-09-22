extends Area2D

@export var is_pressed_moment: bool = false

signal pressed
signal released

func _ready():
	$AnimatedSprite2D.play("released")
	
	# TODO find a way to not have button "collide" with ground (using masks?)
	# - for now the collision shape is 1px smaller than the sprite
func _on_body_entered(_body: Node2D) -> void:
	if not is_pressed_moment:
		is_pressed_moment = true
		$AnimatedSprite2D.play("pressed")
		emit_signal("pressed")
		

func _on_body_exited(_body: Node2D) -> void:
	if is_pressed_moment:
		is_pressed_moment = false
		$AnimatedSprite2D.play("released")
		emit_signal("released")
