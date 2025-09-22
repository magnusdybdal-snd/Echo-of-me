extends AnimatableBody2D

func _ready() -> void:
	$OpenDoor.play_section("Open_door", 0.0,0.01) # TODO proper way of setting position.
	
# Opens door (or replace with proper animation).
func openDoor():
	$OpenDoor.play("Open_door")
	
# Closes door (or replace with proper animation).
func closeDoor():
	$OpenDoor.play_backwards("Open_door")

# Opens door on trigger.
func _on_button_momentary_pressed() -> void:
	openDoor()

# Closes door if button not pressed.
func _on_button_momentary_released() -> void:
	closeDoor()
