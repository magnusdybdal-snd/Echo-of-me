class_name BasePlayerState
# RefCounted is a base class that all nodes extend from
extends RefCounted

## Called when we first enter this state
func enter(_player: CharacterBase) -> void:
	pass
	

## Called when we exit a state
func exit(_player: CharacterBase) -> void:
	pass
	

## Called before update, allows for state changes on the correct physics frame
func pre_update(_player: CharacterBase) -> void:
	pass

## Called every physics framed when we are in this state
func update(_player: CharacterBase, _delta: float) -> void:
	pass
