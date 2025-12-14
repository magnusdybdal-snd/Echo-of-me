extends BaseTrap
class_name DynamicSpikes

@onready var sprite2d = $AnimatedSprite2D

func _ready() -> void:
	super._ready()
	reset_spike()

# Override the base trap behavior
func on_trap_triggered(player: Node2D) -> void:
	trigger_spike()  # Extend the spikes
	super.on_trap_triggered(player)  # Then do the normal trap behavior (freeze/kill)
	# Reset after the trap is done
	await get_tree().create_timer(freeze_duration + 0.5).timeout
	reset_spike()
	
	
# Spike extends 		
func trigger_spike():
	if sprite2d:
		sprite2d.frame = 1

func reset_spike():
	if sprite2d:
		sprite2d.frame = 0
