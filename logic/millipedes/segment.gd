# segment.gd
extends AnimatableBody2D

@export var animation_delay := 0
@export var next_segment : Node2D = null

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

var target_position : Vector2 = Vector2.INF
var to_next_segment : Vector2 = Vector2.ZERO
var target_rotation : float = 0.0

func _ready() -> void:
	if next_segment:
		to_next_segment = next_segment.global_position - global_position

	animation.play("walking")
	animation.frame += animation_delay

func _physics_process(delta):
	if target_position != Vector2.INF:
		var pos = global_position.move_toward(target_position, 500.0 * delta)
		move_and_collide((pos - global_position))
		
	if next_segment:
		var new_next_segment_pos = global_position + to_next_segment.rotated(global_rotation)
		next_segment.set_target_position(new_next_segment_pos, global_rotation)
	
	rotation = target_rotation

func set_target_position(new_target : Vector2, new_rotation : float = 0.0) -> void:
	target_position = new_target
	target_rotation = new_rotation
