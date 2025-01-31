# head.gd
extends AnimatableBody2D

@export var next_segment : Node2D = null

var to_next_segment : Vector2 = Vector2.ZERO

func _ready() -> void:
	if next_segment:
		to_next_segment = next_segment.global_position - global_position

func _physics_process(delta):
	if next_segment:
		var new_next_segment_pos = global_position + to_next_segment.rotated(global_rotation)
		next_segment.set_target_position(new_next_segment_pos, global_rotation)
	
