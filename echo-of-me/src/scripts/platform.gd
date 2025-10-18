extends AnimatableBody2D

enum PlatformType { STATIC, AUTO_MOVE, MOVE_ON_BUTTON_PRESS, MOVE_ON_BUTTON_HOLD, SWITCH_X_AND_Y_POS  }
@export var type: PlatformType = PlatformType.STATIC

var start_position : Vector2
var platform_start_position : Vector2 # x/y platform start position
var start_xform: Transform2D

enum State { MOVE_X, MOVE_Y }
@export var state: State = State.MOVE_X

@export var world_layer: int = 2        # the layer number your world tiles are on
@export var x_speed: float = 80.0
@export var y_speed: float = 80.0
@export var y_min: float = 0.0          # absolute Y coordinates, set in editor
@export var y_max: float = 0.0
@export var x_dir: int = 1               # 1 = right, -1 = left
@export var y_dir: int = 1
@export var ray_x_length: float = 50.0     # how far ahead to check for X collision
@export var ray_y_length: float = 20.0 


@onready var ray: RayCast2D = $"../AxisPlatform/RayCast2D"


# TODO find a way to reset the platforms position.
func _ready():
	start_position = global_position
	var level_controller = get_tree().current_scene.get_node("LevelController")
	level_controller.connect("reset_level", Callable(self, "_on_reset_level"))
	
	match type:
		PlatformType.SWITCH_X_AND_Y_POS:
			start_xform = global_transform
			platform_start_position = global_position
			ray = $RayCast2D
				# Ray looks ahead on X only, checking world layer (mask bit for layer N is (1 << (N-1)) )
			ray.target_position = Vector2(ray_x_length, 0)
			ray.collision_mask = 1 << (world_layer - 1)
			# Make sure updates happen in physics for proper body pushing
			#physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON

func _physics_process(delta: float) -> void:
	match state:
		State.MOVE_X:
			_move_x(delta)
		State.MOVE_Y:
			_move_y(delta)
			
func _move_x(delta: float) -> void:
	match type:
		PlatformType.SWITCH_X_AND_Y_POS:
			# Aim the ray in the current X direction and poll
			ray.target_position = Vector2(ray_x_length * x_dir, 0)
			ray.force_raycast_update()
			if ray.is_colliding(): # Hit the world: change direction
				x_dir = -x_dir
				return
			global_position.x += x_speed * x_dir * delta # No hit: advance along X

func _move_y(delta: float) -> void:
	match type:
		PlatformType.SWITCH_X_AND_Y_POS:
			ray.target_position = Vector2(0, ray_y_length * y_dir)
			ray.force_raycast_update()
			if ray.is_colliding():
				y_dir = -y_dir
				return
			global_position.y += x_speed * y_dir * delta

# Resets position of platform and stops animation
func _on_reset_level():
	print("reset 1")
	global_position = start_position
	if $AnimationPlayer:
		$AnimationPlayer.stop()
	if type == PlatformType.AUTO_MOVE:
		$AnimationPlayer.play($AnimationPlayer.get_animation_list()[0])
	if type == PlatformType.SWITCH_X_AND_Y_POS:
		call_deferred("_do_reset")
		# reset properties
		#global_position = platform_start_position
		
func _do_reset() -> void:
	global_transform = start_xform
	reset_physics_interpolation()
	state = State.MOVE_X
	x_dir = 1

func _on_button_pressed():
	print("entered on button pressed")
	match type:
		PlatformType.MOVE_ON_BUTTON_PRESS, PlatformType.MOVE_ON_BUTTON_HOLD:
			var anims = $AnimationPlayer.get_animation_list()
			$AnimationPlayer.play(anims[0])
	
			

func _on_button_released():
	match type:
		PlatformType.MOVE_ON_BUTTON_HOLD:
			var anims = $AnimationPlayer.get_animation_list()
			$AnimationPlayer.play_backwards(anims[0])


func _on_button_momentary_pressed() -> void:
	if state == State.MOVE_Y:
		state = State.MOVE_X
		x_dir = -x_dir
	else:
		state = State.MOVE_Y
		y_dir = -y_dir
