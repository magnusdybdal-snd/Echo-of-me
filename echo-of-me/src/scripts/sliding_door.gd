extends Node2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var platform_body: AnimatableBody2D = $AnimatableBody2D

var start_position: Vector2

func _ready():
	# Debug: Print what children we have
	print("=== Sliding Door Debug ===")
	print("Children of ", name, ":")
	for child in get_children():
		print("  - ", child.name, " (type: ", child.get_class(), ")")

	# Ensure nodes are ready
	if not platform_body:
		push_error("AnimatableBody2D not found! Check scene structure.")
		return

	if not anim_player:
		push_error("AnimationPlayer not found!")
		return

	# Store the starting position of the platform body (should be 0,0 relative to parent)
	start_position = platform_body.position

	# Connect to level reset
	var level_controller = get_tree().current_scene.get_node("LevelController")
	if level_controller:
		level_controller.connect("reset_level", Callable(self, "_on_reset_level"))

func _on_button_pressed():
	print("Sliding door: Button pressed - opening")
	if anim_player and anim_player.has_animation("Slide"):
		anim_player.play("Slide")

func _on_button_released():
	print("Sliding door: Button released - closing")
	if anim_player and anim_player.has_animation("Slide"):
		anim_player.play_backwards("Slide")

func _on_reset_level():
	print("Sliding door: Resetting")
	# Stop animation
	if anim_player:
		anim_player.stop()

	# Reset platform body to start position
	platform_body.position = start_position

	# Wait one frame for physics sync
	await get_tree().process_frame
