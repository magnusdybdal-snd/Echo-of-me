extends AnimatableBody2D

func rise():
	$Rise.play("rise")


func _on_button_pressed() -> void:
	rise()
