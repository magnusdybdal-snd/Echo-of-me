extends CharacterBody2D

@onready var collision_shape_left: CollisionShape2D = $left/CollisionShapeLeft
@onready var collision_shape_right: CollisionShape2D = $right/CollisionShapeRight

var push = false
var direction = 0
const SPEED = 7000

var start_position : Vector2
var was_in_air := false  # Track if box was in air last frame

# Drag sound player (persistent for looping)
var drag_player: AudioStreamPlayer

func _ready() -> void:
	# Gets the start position of the object
	start_position = global_position
	# Connects to the level controller
	var level_controller = get_tree().current_scene.get_node("LevelController")
	level_controller.connect("reset_level", Callable(self, "_on_reset_level"))

	# Create drag sound player
	drag_player = AudioStreamPlayer.new()
	drag_player.bus = "reverb"
	add_child(drag_player)
	
# Sets the position back to start
func _on_reset_level():
	global_position = start_position
	velocity = Vector2.ZERO
	stop_drag_sound()


func _physics_process(delta: float) -> void:
	# Detect landing
	if was_in_air and is_on_floor():
		AudioPlayer.play_sfx("box_impact", -10.0)

	# Update air state
	was_in_air = not is_on_floor()

	if not is_on_floor():
		velocity += get_gravity() * delta
	if push:
		velocity.x = direction * delta * SPEED
		play_drag_sound()
	else:
		velocity.x = 0
		stop_drag_sound()

	move_and_slide()

	


func _on_left_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		direction = 1
		push = true


func _on_left_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		direction = 0
		push = false


func _on_right_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		direction = -1
		push = true


func _on_right_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		direction = 0
		push = false

# Plays drag sound (looping)
func play_drag_sound():
	if drag_player != null and not drag_player.playing:
		if "box_drag" in AudioPlayer.sfx_collections:
			var sounds = AudioPlayer.sfx_collections["box_drag"]
			if sounds.size() > 0:
				drag_player.stream = sounds[0]
				drag_player.play()

# Stops drag sound
func stop_drag_sound():
	if drag_player != null and drag_player.playing:
		drag_player.stop()
