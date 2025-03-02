extends Node2D

@export var ritter : Knight
@onready var target: Node2D = $Target

var distance_to_target : float
var target_destination : Vector2

signal ritter_detected(ritter: Knight)
signal ritter_lost
func _ready():
	# Distance to target from the target's parent center
	# Target should be initially set up on the farthest segment of the antenna
	distance_to_target = target.position.length()
	target_destination = target.position

func _process(delta):
	if not ritter or global_position.distance_to(ritter.global_position) > distance_to_target * 2:
		target.position = target.position.lerp(target_destination, 0.05)
		if target.position.distance_to(target_destination) < 1.0:
			var angle = randf_range(-PI, PI)
			var radius = distance_to_target
			target_destination = position + Vector2(radius * cos(angle), radius * sin(angle))
	else:
		var distance_to_ritter = global_position.distance_to(ritter.global_position)
		var direction_to_ritter = global_position.direction_to(ritter.global_position)

		var new_target_pos = global_position + direction_to_ritter * min(
			distance_to_ritter, distance_to_target
			)
		target.global_position = target.global_position.lerp(new_target_pos, 0.5)

		if distance_to_ritter > distance_to_target:
			ritter_lost.emit()

func _on_area_2d_body_entered(body: Node2D):
	if body is Knight:
		ritter = body
		ritter_detected.emit(ritter)


