extends Area2D
class_name BaseTrap

@export var freeze_duration: float = 1.0
@export var kill_player: bool = true
@onready var level_controller := get_tree().current_scene.get_node("LevelController")

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		on_trap_triggered(body)

func on_trap_triggered(player: Node2D) -> void:
	# Override this in child classes for custom behavior
	freeze_player(player)
	
	if kill_player:
		await get_tree().create_timer(freeze_duration).timeout
		if is_instance_valid(level_controller):
			level_controller.hard_reset()

func freeze_player(player: Node2D) -> void:
	if player is CharacterBase:
		player.die()  # This handles everything cleanly
	else:
		# Fallback for non-CharacterBase nodes
		player.set_process_input(false)
		player.set_process(false)
		player.set_physics_process(false)
		
		if player.has_node("AnimatedSprite2D"):
			var sprite = player.get_node("AnimatedSprite2D")
			sprite.pause()
