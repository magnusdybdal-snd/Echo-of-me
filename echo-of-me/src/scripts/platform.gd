extends AnimatableBody2D

enum PlatformType { STATIC, AUTO_MOVE, MOVE_ON_BUTTON_PRESS, MOVE_ON_BUTTON_HOLD  }
@export var type: PlatformType = PlatformType.STATIC

var start_position : Vector2

func _ready():
	start_position = global_position
	var level_controller = get_tree().current_scene.get_node("LevelController")
	level_controller.connect("reset_level", Callable(self, "_on_reset_level"))
		
# Resets position of platform and stops animation
func _on_reset_level():
	global_position = start_position
	if $AnimationPlayer:
		$AnimationPlayer.stop()
	if type == PlatformType.AUTO_MOVE:
		$AnimationPlayer.play($AnimationPlayer.get_animation_list()[0])

func _on_button_pressed():
	match type:
		PlatformType.MOVE_ON_BUTTON_PRESS, PlatformType.MOVE_ON_BUTTON_HOLD:
			var anims = $AnimationPlayer.get_animation_list()
			$AnimationPlayer.play(anims[0])

func _on_button_released():
	match type:
		PlatformType.MOVE_ON_BUTTON_HOLD:
			var anims = $AnimationPlayer.get_animation_list()
			$AnimationPlayer.play_backwards(anims[0])
