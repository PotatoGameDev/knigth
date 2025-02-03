# segment.gd
extends AnimatableBody2D

@export var animation_delay := 0
@export var leader : Node2D = null

const MIN_DISTANCE_TO_LEADER := 1.0

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

var target_position : Vector2 = Vector2.INF
var target_rotation : float = 0.0
var leader_to_me : Vector2 = Vector2.ZERO

func _ready() -> void:
	leader_to_me = global_position - leader.global_position
	target_position = leader.global_position + leader_to_me.rotated(leader.global_rotation)
	target_rotation = leader.global_rotation

	animation.play("walking")
	animation.frame += animation_delay

func _physics_process(delta):
	
	if target_position.is_equal_approx(global_position):
		target_position = leader.global_position + leader_to_me.rotated(leader.global_rotation)
		target_rotation = leader.global_rotation

	var pos = global_position.move_toward(target_position, 150.0 * delta)
	move_and_collide((pos - global_position))

	global_rotation = lerp_angle(global_rotation, target_rotation, 5 * delta)
