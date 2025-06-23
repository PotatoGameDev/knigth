extends Node2D

const SEGMENT_COUNT := 20
const BONE_LENGTH := 64.0
const DAMPING := 0.4

var joints: Array[Vector2] = []
var target_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	for i in range(SEGMENT_COUNT):
		joints.append(Vector2(i * BONE_LENGTH, 0))

func _process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		target_position = get_global_mouse_position()
		move_snake_toward_target(target_position)

	queue_redraw()

func move_snake_toward_target(target: Vector2) -> void:
	# Move head toward target
	joints[0] = joints[0].lerp(target, DAMPING)

	# Move each joint to follow the previous one
	for i in range(1, SEGMENT_COUNT):
		var direction := (joints[i] - joints[i - 1]).normalized()
		joints[i] = joints[i - 1] + direction * BONE_LENGTH

func _draw() -> void:
	for i in range(SEGMENT_COUNT - 1):
		draw_line(joints[i], joints[i + 1], Color.LIME_GREEN, 2.0)
