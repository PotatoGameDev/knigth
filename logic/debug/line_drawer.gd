extends Node2D
class_name LineDrawer

@export var max_trail_length := 20  # Adjust for longer or shorter trail
@export var enabled := true

var trail_points := []

func _physics_process(_delta):
	if trail_points.size() != 0:
		var last_element = trail_points[trail_points.size() - 1]
		if last_element == global_position:
			return

	trail_points.append(global_position)
	if trail_points.size() > max_trail_length:
		trail_points.pop_front()
	queue_redraw()

func _draw():
	if !enabled:
		return
	for i in range(trail_points.size() - 1):
		var point1 = to_local(trail_points[i])
		draw_circle(point1, 2, Color(1, 0, 0))
		var point2 = to_local(trail_points[i + 1])
		draw_line(point1, point2, Color(1, 0, 0), 2)
