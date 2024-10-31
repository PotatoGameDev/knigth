extends Node2D
class_name LineDrawer

@export var max_trail_length = 20  # Adjust for longer or shorter trail

var trail_points = []

func _process(_delta):
	trail_points.append(global_position)
	if trail_points.size() > max_trail_length:
		trail_points.pop_front()  # Limit trail length
	queue_redraw()

func _draw():
	for i in range(trail_points.size() - 1):
		var point1 = to_local(trail_points[i])
		var point2 = to_local(trail_points[i + 1])
		draw_line(point1, point2, Color(1, 0, 0), 2)  # Adjust color and width as needed
