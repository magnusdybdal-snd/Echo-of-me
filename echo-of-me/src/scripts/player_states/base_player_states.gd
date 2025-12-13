class_name BasePlayerState
# RefCounted is a base class that all nodes extend from
extends RefCounted

## Called when we first enter this state
func enter(player: CharacterBase) -> void:
	pass
	

## Called when we exit a state
func exit(player: CharacterBase) -> void:
	pass
	

## Called before update, allows for state changes on the correct physics frame
func pre_update(player: CharacterBase) -> void:
	pass

## Called every physics framed when we are in this state
func update(player: CharacterBase, delta: float) -> void:
	pass
