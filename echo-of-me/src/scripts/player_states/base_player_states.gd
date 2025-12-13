class_name BasePlayerState
# RefCounted is a base class that all nodes extend from
extends RefCounted

## Called when we first enter this state
func enter() -> void:
	pass
	

## Called when we exit a state
func exit() -> void:
	pass
	

## Called every physics framed when we are in this state
func update(delta: float) -> void:
	pass
