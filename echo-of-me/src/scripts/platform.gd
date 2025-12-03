extends AnimatableBody2D

enum PlatformType { STATIC, AUTO_MOVE, MOVE_ON_BUTTON_PRESS, MOVE_ON_BUTTON_HOLD, SWITCH_X_AND_Y_POS, MOVE_ON_BUTTON_HOLD_BACK_AND_FORTH }
enum State { MOVE_X, MOVE_Y }

# Exported variables (editable in Inspector)
@export var type: PlatformType = PlatformType.STATIC
@export var state: State = State.MOVE_X
@export var world_layer: int = 2
@export var x_speed: float = 80.0
@export var y_speed: float = 80.0
@export var y_min: float = 0.0
@export var y_max: float = 0.0
@export var x_dir: int = 1
@export var y_dir: int = 1
@export var ray_x_length: float = 50.0
@export var ray_y_length: float = 20.0

# Internal variables (not exported)
var start_position: Vector2
var start_global_position: Vector2
var platform_start_position: Vector2
var start_xform: Transform2D
var initial_x_dir: int
var initial_y_dir: int
var initial_state: State
var is_resetting: bool = false
var ray: RayCast2D = null

func _ready():
	start_position = global_position
	platform_start_position = global_position
	start_global_position = global_position
	start_xform = global_transform
	
	var level_controller = get_tree().current_scene.get_node("LevelController")
	level_controller.connect("reset_level", Callable(self, "_on_reset_level"))
	
	# Store initial values for reset
	initial_x_dir = x_dir
	initial_y_dir = y_dir
	initial_state = state
	
	match type:
		PlatformType.SWITCH_X_AND_Y_POS:
			if has_node("RayCast2D"):
				ray = $RayCast2D
				ray.target_position = Vector2(ray_x_length, 0)
				ray.collision_mask = 1 << (world_layer - 1)
			else:
				print("Warning: RayCast2D not found on platform - SWITCH_X_AND_Y_POS won't work properly")

func _physics_process(delta: float) -> void:
	# Don't move if we're in the middle of resetting
	if is_resetting:
		return
		
	match state:
		State.MOVE_X:
			_move_x(delta)
		State.MOVE_Y:
			_move_y(delta)
			
func _move_x(delta: float) -> void:
	match type:
		PlatformType.SWITCH_X_AND_Y_POS:
			if ray == null:
				return
			ray.target_position = Vector2(ray_x_length * x_dir, 0)
			ray.force_raycast_update()
			if ray.is_colliding():
				x_dir = -x_dir
				return
			global_position.x += x_speed * x_dir * delta

func _move_y(delta: float) -> void:
	match type:
		PlatformType.SWITCH_X_AND_Y_POS:
			if ray == null:
				return
			ray.target_position = Vector2(0, ray_y_length * y_dir)
			ray.force_raycast_update()
			if ray.is_colliding():
				y_dir = -y_dir
				return
			global_position.y += y_speed * y_dir * delta

func _on_reset_level():
	print("Platform reset triggered - Type: ", type)
	
	# Set resetting flag to stop movement
	is_resetting = true
	
	# Stop any animations
	if has_node("AnimationPlayer"):
		$AnimationPlayer.stop()
	
	match type:
		PlatformType.AUTO_MOVE:
			# For animated platforms, reset position first
			global_position = start_position
			
			# Wait one frame for physics to sync
			await get_tree().process_frame
			
			# Restart animation
			if has_node("AnimationPlayer"):
				$AnimationPlayer.play($AnimationPlayer.get_animation_list()[0])
			is_resetting = false
		
		PlatformType.SWITCH_X_AND_Y_POS:
			# Reset all state variables immediately
			state = initial_state
			x_dir = initial_x_dir
			y_dir = initial_y_dir
			
			# Method 1: Direct position set
			global_position = platform_start_position
			
			# Method 2: Transform reset
			global_transform = start_xform
			
			# Wait for physics to process the change
			await get_tree().physics_frame
			
			# Reset physics interpolation for smooth repositioning
			reset_physics_interpolation()
			
			# Wait one more frame to ensure collision is properly updated
			await get_tree().physics_frame
			
			is_resetting = false
			
		_:
			# For other types, just reset position
			await get_tree().process_frame
			global_position = start_position

			is_resetting = false

func _on_button_pressed():
	print("Button pressed - platform activating")
	match type:
		PlatformType.MOVE_ON_BUTTON_PRESS, PlatformType.MOVE_ON_BUTTON_HOLD, PlatformType.MOVE_ON_BUTTON_HOLD_BACK_AND_FORTH:
			if has_node("AnimationPlayer"):
				var anims = $AnimationPlayer.get_animation_list()
				if anims.size() > 0:
					$AnimationPlayer.play(anims[0])
			
func _on_button_released():
	match type:
		PlatformType.MOVE_ON_BUTTON_HOLD:
			if has_node("AnimationPlayer"):
				var anims = $AnimationPlayer.get_animation_list()
				if anims.size() > 0:
					$AnimationPlayer.play_backwards(anims[0])
		PlatformType.MOVE_ON_BUTTON_HOLD_BACK_AND_FORTH:
			if has_node("AnimationPlayer"):
				var anims = $AnimationPlayer.get_animation_list()
				if anims.size() > 0:
					$AnimationPlayer.pause()

func _on_button_momentary_pressed() -> void:
	if state == State.MOVE_Y:
		state = State.MOVE_X
		x_dir = -x_dir
	else:
		state = State.MOVE_Y
		y_dir = -y_dir
