extends Node2D

enum SlideDirection  { LEFT, RIGHT }
enum DoorType { NORMAL, TIMER }

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var platform_body: AnimatableBody2D = $AnimatableBody2D

@export var slide_direction : SlideDirection = SlideDirection.RIGHT
@export var door_type: DoorType = DoorType.NORMAL
@export var anim_speed_scale: float = 10.0 # Standard for fast open/close doors

var start_position: Vector2

func _ready():
	# Store the starting position of the platform body (should be 0,0 relative to parent)
	start_position = platform_body.position
	
	# Sets the animation speed scale of the door
	if anim_player:
		anim_player.speed_scale = anim_speed_scale

	# Connect to level reset
	var level_controller = get_tree().current_scene.get_node("LevelController")
	if level_controller:
		level_controller.connect("reset_level", Callable(self, "_on_reset_level"))

func _on_button_pressed():
	if anim_player:
		match door_type:
			DoorType.NORMAL:
				match slide_direction:
					SlideDirection.RIGHT:
						anim_player.play("SlideRight")
					SlideDirection.LEFT:
						anim_player.play("SlideLeft")
			DoorType.TIMER:
				anim_player.play("TimerOpen")


func _on_button_released():
	if anim_player:
		match door_type:
			DoorType.NORMAL:
				match slide_direction:
					SlideDirection.RIGHT:
						anim_player.play_backwards("SlideRight")
					SlideDirection.LEFT:
						anim_player.play_backwards("SlideLeft")
			DoorType.TIMER:
				anim_player.play("TimerClose")

func _on_reset_level():
	print("Sliding door: Resetting")
	# Stop animation
	if anim_player:
		anim_player.stop()

	# Reset platform body to start position
	platform_body.position = start_position

	# Wait one frame for physics sync
	await get_tree().process_frame
