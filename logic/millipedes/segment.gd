# segment.gd
extends AnimatableBody2D

@export var animation_delay := 0
@export var follower : Node2D = null
@export var leader : Node2D = null

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

const MIN_DISTANCE_TO_LEADER := 1.0

var target_distance_to_leader : float 

var turn_speed := 100.0
var max_move_speed := 300.0

var positions : Array[Vector2] = []
var rotations : Array[float] = []

var direction := 1.0

func _ready() -> void:
	animation.play("walking")
	animation.frame += animation_delay

	if follower:
		follower.leader = self
		target_distance_to_leader = leader.global_position.distance_to(global_position)

func _physics_process(delta):
	animation.flip_h = direction == Global.LEFT
	if follower:
		follower.direction = direction

	if positions.size() == 0:
		return

	var target_pos = positions.front()
	var target_rot = rotations.front()
	
	var current_distance_to_leader = leader.global_position.distance_to(global_position)
	var move_speed = lerp(
		0.0, 
		max_move_speed, 
		current_distance_to_leader/target_distance_to_leader
		)

	var new_pos = global_position.move_toward(target_pos, max_move_speed * delta)

	# This makes it not affected by physics:
	global_position = new_pos
	# This makes it affected by physics:
	#move_and_collide(new_pos - global_position)

	global_rotation = lerp_angle(global_rotation, target_rot, turn_speed * delta)

	if global_position.is_equal_approx(target_pos):
		if follower:
			follower.add_target(target_pos, target_rot)
		positions.pop_front()
		rotations.pop_front()
		return

func add_target(target_position : Vector2, target_rotation) -> void:
	positions.append(target_position)
	rotations.append(target_rotation)

func init(target_position : Vector2, target_rotation) -> void:
	positions.append(target_position)
	rotations.append(target_rotation)
	if follower:
		follower.init(target_position, target_rotation)
