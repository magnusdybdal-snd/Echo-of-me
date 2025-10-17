extends RigidBody2D

const DAMP_FORCE = 800.0
const STOP_THRESHOLD = 20.0
const MAX_PUSH_SPEED = 220.0

var start_position : Vector2
var beeing_pushed := false
var pusher: CharacterBody2D = null

func _ready():
	start_position = global_position
	
	if physics_material_override == null:
		physics_material_override = PhysicsMaterial.new()
		
	physics_material_override.friction = 1.0
	physics_material_override.bounce = 0.0
	
	var level_controller = get_tree().current_scene.get_node("LevelController")
	level_controller.connect("reset_level", Callable(self, "_on_reset_level"))

func _physics_process(_delta: float) -> void:
	if beeing_pushed and is_instance_valid(pusher):
		linear_damp = 4.5
		mass = 1.0
		
		var max_speed = abs(pusher.velocity.x) * 1.1
		if abs(linear_velocity.x) > max_speed:
			linear_velocity.x = sign(linear_velocity.x) * max_speed		
	else:
		linear_damp = 0.0
		mass = 0.5
		pusher = null

# Handles reseting of position when level is reset with E or R
func _on_reset_level():
	freeze = true
	PhysicsServer2D.body_set_state(
	get_rid(),
	PhysicsServer2D.BODY_STATE_TRANSFORM,
	Transform2D.IDENTITY.translated(start_position)
	)
	global_position = start_position
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	freeze = false
	beeing_pushed = false
	pusher = null

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("enter")
	if body.has_method("add_nearby_box"):
		body.add_nearby_box(self)
		beeing_pushed = true
		pusher = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	print("exit")
	if body.has_method("remove_nearby_box"):
		body.remove_nearby_box(self)
		beeing_pushed = false
		pusher = null
