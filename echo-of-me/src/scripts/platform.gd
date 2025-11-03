extends AnimatableBody2D
enum PlatformType { STATIC, AUTO_MOVE, MOVE_ON_BUTTON_PRESS, MOVE_ON_BUTTON_HOLD, SWITCH_X_AND_Y_POS  }
@export var type: PlatformType = PlatformType.STATIC
var start_position : Vector2
var platform_start_position : Vector2 # x/y platform start position
var start_xform: Transform2D
var initial_x_dir: int  # Store initial direction
var initial_y_dir: int  # Store initial direction
var initial_state: State  # Store initial state
var is_resetting: bool = false  # Flag to prevent movement during reset
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
@onready var ray: RayCast2D = null

func _ready():
	start_position = global_position
	var level_controller = get_tree().current_scene.get_node("LevelController")
	level_controller.connect("reset_level", Callable(self, "_on_reset_level"))
	
	# Store initial values for reset
	initial_x_dir = x_dir
	initial_y_dir = y_dir
	initial_state = state
	
	match type:
		PlatformType.SWITCH_X_AND_Y_POS:
			start_xform = global_transform
			platform_start_position = global_position
			# Check if this node has a RayCast2D child
			if has_node("RayCast2D"):
				ray = $RayCast2D
				# Ray looks ahead on X only, checking world layer (mask bit for layer N is (1 << (N-1)) )
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
			if ray == null:
				return
			ray.target_position = Vector2(0, ray_y_length * y_dir)
			ray.force_raycast_update()
			if ray.is_colliding():
				y_dir = -y_dir
				return
			global_position.y += y_speed * y_dir * delta

# Resets position of platform and stops animation
func _on_reset_level():
	print("Platform reset triggered - Type: ", type)
	
	# Set resetting flag to stop movement
	is_resetting = true
	
	# Stop any animations
	if has_node("AnimationPlayer"):
		$AnimationPlayer.stop()
	
	match type:
		PlatformType.AUTO_MOVE:
			global_position = start_position
			# Use sync_to_physics to ensure the physics engine knows about the position change
			sync_to_physics = true
			await get_tree().physics_frame
			sync_to_physics = false
			
			if has_node("AnimationPlayer"):
				$AnimationPlayer.play($AnimationPlayer.get_animation_list()[0])
			is_resetting = false
		
		PlatformType.SWITCH_X_AND_Y_POS:
			# Reset all state variables immediately
			state = initial_state
			x_dir = initial_x_dir
			y_dir = initial_y_dir
			
			# Use multiple approaches to ensure position resets
			# First, set the position directly
			global_position = platform_start_position
			position = start_position
			
			# Force physics sync
			sync_to_physics = true
			
			# Wait for physics frame to process
			await get_tree().physics_frame
			
			# Set transform as backup
			global_transform = start_xform
			
			# Reset physics interpolation
			reset_physics_interpolation()
			
			# Wait another frame to ensure everything is synced
			await get_tree().physics_frame
			
			sync_to_physics = false
			is_resetting = false
			
			print("Platform reset complete - Position: ", global_position, " State: ", state, " X_dir: ", x_dir, " Y_dir: ", y_dir)
		
		_:
			# For other types, just reset position
			global_position = start_position
			sync_to_physics = true
			await get_tree().physics_frame
			sync_to_physics = false
			is_resetting = false

func _on_button_pressed():
	print("entered on button pressed")
	match type:
		PlatformType.MOVE_ON_BUTTON_PRESS, PlatformType.MOVE_ON_BUTTON_HOLD:
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

func _on_button_momentary_pressed() -> void:
	if state == State.MOVE_Y:
		state = State.MOVE_X
		x_dir = -x_dir
	else:
		state = State.MOVE_Y
		y_dir = -y_dir
