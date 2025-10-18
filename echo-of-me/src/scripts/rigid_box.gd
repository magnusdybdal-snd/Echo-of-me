extends RigidBody2D

var start_position : Vector2
var beeing_pushed := false

func _ready():
	start_position = global_position
	
	if physics_material_override == null:
		physics_material_override = PhysicsMaterial.new()
		
	physics_material_override.friction = 1.0
	physics_material_override.bounce = 0.0
	
	var level_controller = get_tree().current_scene.get_node("LevelController")
	level_controller.connect("reset_level", Callable(self, "_on_reset_level"))

func _physics_process(_delta: float) -> void:
	if beeing_pushed:
		physics_material_override.friction = 0.0
	else:
		physics_material_override.friction = 1.0
			
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

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("add_nearby_box"):
		body.add_nearby_box(self)
		beeing_pushed = true
		linear_damp = 0.0
		add_collision_exception_with(body)

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.has_method("remove_nearby_box"):
		body.remove_nearby_box(self)
		beeing_pushed = false
		linear_velocity.x = 0.0
		remove_collision_exception_with(body)
