# head.gd
extends AnimatableBody2D

@onready var animation: Sprite2D = $Sprite2D
@export var follower : Node2D = null

var me_to_follower : Vector2
var current_follower_target_position : Vector2
var current_follower_target_rotation : float

const MIN_DISTANCE_TO_LEADER := 0.0

var direction := Global.RIGHT

func _ready() -> void:
	me_to_follower = follower.global_position - global_position
	current_follower_target_position = follower.global_position
	current_follower_target_rotation = global_rotation

	follower.leader = self
	follower.init(current_follower_target_position, current_follower_target_rotation)

func _physics_process(delta):
	var follower_target = global_position \
			+ (me_to_follower * Vector2(direction, 1)).rotated(global_rotation)
	
	current_follower_target_position = follower_target
	current_follower_target_rotation = global_rotation
	follower.add_target(
		current_follower_target_position, 
		current_follower_target_rotation
	)

	animation.flip_h = direction == Global.LEFT
	follower.direction = direction
