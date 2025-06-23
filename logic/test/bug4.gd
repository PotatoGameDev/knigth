extends Node2D

const SEGMENT_COUNT := 20
const BONE_LENGTH := 20.0
const SEGMENT_SPEED := 200.0
const MIN_SPACING := 18.0

var segment_positions: Array[Vector2] = []
var trails: Array[Array] = []

var target_position := Vector2.ZERO

func _ready() -> void:
	var start = Vector2(100, 300)
	for i in range(SEGMENT_COUNT):
		segment_positions.append(start - Vector2(i * BONE_LENGTH, 0))
		trails.append([])
	target_position = segment_positions[0]

func _process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		target_position = get_global_mouse_position()

	move_segments_with_checkpoint_following(delta)
	queue_redraw()

func move_segments_with_checkpoint_following(delta: float) -> void:
	# Move head
	var head = segment_positions[0]
	var to_target = target_position - head
	var move = to_target.normalized() * SEGMENT_SPEED * delta
	if move.length() > to_target.length():
		move = to_target
	head += move
	segment_positions[0] = head

	# Head adds to trail
	trails[0].append(head)

	# Each follower uses previous segment’s trail
	for i in range(1, SEGMENT_COUNT):
		var trail = trails[i - 1]
		if trail.is_empty():
			continue

		var pos = segment_positions[i]
		var target_point = trail[0]
		var to_next = target_point - pos
		var dist = to_next.length()

		if dist > 0.1:
			var move_vec = to_next.normalized() * SEGMENT_SPEED * delta
			if move_vec.length() > dist:
				move_vec = to_next
			segment_positions[i] += move_vec

		# Remove trail points as we pass them
		if dist < MIN_SPACING and trail.size() > 1:
			trail.remove_at(0)

		# Add to this segment’s trail for the next follower
		trails[i].append(segment_positions[i])

func _draw() -> void:
	for i in range(SEGMENT_COUNT - 1):
		draw_line(segment_positions[i], segment_positions[i + 1], Color.LIGHT_GOLDENROD, 2.5)
