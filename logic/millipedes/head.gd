# head.gd
extends AnimatableBody2D

@onready var animation: Sprite2D = $Sprite2D
@export var follower : Node2D = null
@export var path_follow : PathFollow2D = null
@export var speed := 100.0

var direction := Global.RIGHT
var distance_to_follower : float

func _ready() -> void:
	if follower:
		distance_to_follower = follower.global_position.distance_to(global_position)

	if path_follow:
		path_follow.get_children()[0].update_position = true
		path_follow.get_children()[0].update_rotation = true
		path_follow.get_children()[0].remote_path = get_path()

func _process(delta):
	if path_follow:
		if path_follow.progress_ratio >= 1.0 and direction == Global.RIGHT:
			direction = Global.LEFT
		elif path_follow.progress_ratio <= 0.0 and direction == Global.LEFT:
			direction = Global.RIGHT

		path_follow.progress += delta * speed * direction

		print(path_follow.progress, " ", distance_to_follower)

		if follower:
			follower.update_progress(path_follow.progress - distance_to_follower)

	animation.flip_h = direction == Global.LEFT
	if follower:
		follower.direction = direction
