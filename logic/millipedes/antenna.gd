extends Node2D

@export var ritter : Knight

@onready var target: Node2D = $Target

var distance_to_target : float

func _ready():
	# Distance to target from the target's parent center
	# Target should be initially set up on the farthest segment of the antenna
	distance_to_target = target.position.length()

func _process(delta):
	if not ritter:
		return

	var distance_to_ritter = global_position.distance_to(ritter.global_position)
	var direction_to_ritter = global_position.direction_to(ritter.global_position)

	target.global_position = global_position + direction_to_ritter * min(
		distance_to_ritter, distance_to_target
		)
	queue_redraw()

func _draw() -> void:
	draw_line(Vector2.ZERO, target.position, Color.RED)

