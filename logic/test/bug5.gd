extends Node2D

const SEGMENT_COUNT := 20
const BONE_LENGTH := 20.0
const SEGMENT_SPEED := 200.0

var segment_positions: Array = []
var trails: Array = []
var last_directions: Array = []

var target_position := Vector2.ZERO

func _ready() -> void:
	var start = Vector2(100, 300)
	for i in range(SEGMENT_COUNT):
		segment_positions.append(start - Vector2(i * BONE_LENGTH, 0))
		trails.append([])
		last_directions.append(Vector2.RIGHT)  # initial direction
	target_position = segment_positions[0]

func _process(delta: float) -> void:
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		target_position = get_global_mouse_position()

	move_segments(delta)
	queue_redraw()

func move_segments(delta: float) -> void:
	# Move head toward target
	var head_pos = segment_positions[0]
	var to_target = target_position - head_pos
	if to_target.length() > 1.0:
		var move = to_target.normalized() * min(SEGMENT_SPEED * delta, to_target.length())
		head_pos += move
		segment_positions[0] = head_pos
		trails[0].append(head_pos)
		last_directions[0] = move.normalized() if move.length() > 0 else last_directions[0]

	# Move followers
	for i in range(1, SEGMENT_COUNT):
		var pos = segment_positions[i]
		var leader_trail = trails[i - 1]

		# Find next trail point that is at least BONE_LENGTH away
		var next_point_found = false
		while leader_trail.size() >= 2:
			var dist = (leader_trail[0] - pos).length()
			if dist >= BONE_LENGTH:
				next_point_found = true
				break
			leader_trail.remove_at(0)  # discard too-close points

		if next_point_found:
			var target_point = leader_trail[0]
			var direction = (target_point - pos).normalized()
			var move_vec = direction * SEGMENT_SPEED * delta
			if move_vec.length() > (target_point - pos).length():
				move_vec = target_point - pos
			segment_positions[i] += move_vec
			last_directions[i] = direction
		else:
			# No next trail point, keep moving in last direction if spacing requires it
			var dir = last_directions[i]
			var leader_pos = segment_positions[i - 1]
			var dist_to_leader = (leader_pos - pos).length()

			if dist_to_leader > BONE_LENGTH:
				var move_vec = dir * SEGMENT_SPEED * delta
				segment_positions[i] += move_vec
			else:
				# Close enough, stop moving
				pass

		# Append current pos to trail for next segment
		trails[i].append(segment_positions[i])

func _draw() -> void:
	for i in range(SEGMENT_COUNT - 1):
		draw_line(segment_positions[i], segment_positions[i + 1], Color.SEA_GREEN, 3.0)
