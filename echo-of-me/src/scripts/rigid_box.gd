extends RigidBody2D

const DAMP_FORCE = 2000.0
const STOP_THRESHOLD = 5.0

var start_position : Vector2
var beeing_pushed := false

func _ready():
	start_position = global_position
	var level_controller = get_tree().current_scene.get_node("LevelController")
	level_controller.connect("reset_level", Callable(self, "_on_reset_level"))

func _physics_process(delta: float) -> void:
	if not beeing_pushed:
		linear_velocity.x = move_toward(linear_velocity.x, 0, DAMP_FORCE * delta)
		if abs(linear_velocity.x) < STOP_THRESHOLD:
			linear_velocity.x = 0




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
	print("enter")
	beeing_pushed = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	print("exit")
	beeing_pushed = false
