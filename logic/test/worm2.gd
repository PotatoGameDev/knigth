extends Node2D

const SEGMENT_COUNT := 20
const BONE_LENGTH := 20.0
const HEAD_SPEED := 400.0
const FOLLOW_SPEED := 600.0  # Speed segments catch up

var joints: Array[Vector2] = []
var target_position: Vector2

func _ready() -> void:
	var start = Vector2(100, 300)
	for i in range(SEGMENT_COUNT):
		joints.append(start - Vector2(i * BONE_LENGTH, 0))
	target_position = joints[0]

func _process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		target_position = get_global_mouse_position()

	move_dynamic_chain(delta)
	queue_redraw()

func move_dynamic_chain(delta: float) -> void:
	# Move the head toward the target
	var head = joints[0]
	var to_target = target_position - head
	var move = to_target.normalized() * HEAD_SPEED * delta
	if move.length() > to_target.length():
		move = to_target
	joints[0] += move

	# Move each segment toward the previous one dynamically
	for i in range(1, SEGMENT_COUNT):
		var prev = joints[i - 1]
		var curr = joints[i]
		var to_prev = prev - curr
		var dist = to_prev.length()

		if dist > BONE_LENGTH:
			var move_dir = to_prev.normalized()
			var overshoot = dist - BONE_LENGTH
			var max_move = FOLLOW_SPEED * delta
			var move_amount = min(overshoot, max_move)
			joints[i] += move_dir * move_amount
		else:
			# Keep proper spacing
			joints[i] = prev - to_prev.normalized() * BONE_LENGTH

func _draw() -> void:
	for i in range(SEGMENT_COUNT - 1):
		draw_line(joints[i], joints[i + 1], Color(0,1,0), 3)
