extends RigidBody2D

# Trap settings
@export var shake_duration: float = 0.3
@export var shake_intensity: float = 2.0
@export var respawn_time: float = 3.0

var is_falling: bool = false
var is_triggered: bool = false
var original_position: Vector2
var shake_timer: float = 0.0

@onready var trigger_area = $TriggerArea
@onready var damage_area = $DamageArea
@onready var sprite = $Sprite2D

func _ready():
	# Store original position for respawn
	original_position = global_position
	
	# Connect to level controller reset
	var level_controller = get_tree().current_scene.get_node("LevelController")
	level_controller.connect("reset_level", Callable(self, "_on_level_reset"))
	
	# Start as static (won't fall until triggered)
	freeze = true
	gravity_scale = 0
	
	# Connect signals
	trigger_area.body_entered.connect(_on_trigger_area_entered)
	damage_area.body_entered.connect(_on_damage_area_entered)

func _on_trigger_area_entered(body):
	# Trigger when player (or echo) walks underneath
	if (body.is_in_group("player") or body.collision_layer & 4) and not is_triggered:
		trigger_fall()

func trigger_fall():
	is_triggered = true
	shake_timer = shake_duration

func _process(delta):
	if shake_timer > 0:
		# Shake before falling
		shake_timer -= delta
		sprite.position.x = randf_range(-shake_intensity, shake_intensity)
		
		if shake_timer <= 0:
			sprite.position.x = 0
			start_falling()

func start_falling():
	# Enable physics and gravity
	is_falling = true
	freeze = false
	gravity_scale = 1.0

func _on_damage_area_entered(body):
	# Only damage player if falling fast enough
	# TODO: linear_velocity NEEDS TO BE TINKERED WITH OUTSIDE OF TEST LEVEL
	if body.is_in_group("player") and linear_velocity.y > 7.0:  # Adjust threshold as needed
		var level_controller = get_tree().current_scene.get_node("LevelController")
		level_controller.hard_reset()


func _on_level_reset() -> void:
	is_falling = false
	is_triggered = false
	
	# Completely stop all physics
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	freeze = true
	gravity_scale = 0
	
	# Wait for physics to process the freeze
	await get_tree().physics_frame
	
	# Reset position after physics has stopped
	global_position = original_position
	rotation = 0
	sprite.position = Vector2.ZERO
	
	# Ensure velocity is still zero after position change
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	
	# Show immediately
	visible = true
