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
	# Disable player input processing
	player.set_process_input(false)
	player.set_process(false)
	player.set_physics_process(false)
	
	# Stop all animations
	if player.has_node("AnimatedSprite2D"):
		var sprite = player.get_node("AnimatedSprite2D")
		sprite.pause()
	elif player.has_node("AnimationPlayer"):
		var anim_player = player.get_node("AnimationPlayer")
		anim_player.pause()
	
	# Freeze physics
	if player is CharacterBody2D or player is RigidBody2D:
		player.velocity = Vector2.ZERO
		if player is RigidBody2D:
			player.linear_velocity = Vector2.ZERO
			player.angular_velocity = 0.0
			player.freeze = true
