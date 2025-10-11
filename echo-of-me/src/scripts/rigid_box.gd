extends RigidBody2D

const FRICTION := 1000

var start_position : Vector2
var is_being_pushed := false

func _ready():
	start_position = global_position
	var level_controller = get_tree().current_scene.get_node("LevelController")
	level_controller.connect("reset_level", Callable(self, "_on_reset_level"))
	
func _physics_process(delta: float) -> void:
	if not is_being_pushed:
		linear_velocity.x = move_toward(linear_velocity.x, 0, FRICTION * delta)

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

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Body entered: ", body.name, " Groups: ", body.get_groups())
		is_being_pushed = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Body exited: ", body.name, " Groups: ", body.get_groups())
		is_being_pushed = false
