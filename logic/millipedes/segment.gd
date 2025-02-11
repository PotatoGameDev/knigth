# segment.gd
extends AnimatableBody2D

@export var animation_delay := 0
@export var follower : Node2D = null
@export var path_follow : PathFollow2D = null

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

var direction := 1.0
var distance_to_follower : float

func _ready() -> void:
	animation.play("walking")
	# get the animation length in godot frames
	var frames_count = animation.sprite_frames.get_frame_count(animation.animation)
	animation.frame += animation_delay % frames_count

	if follower:
		distance_to_follower = follower.global_position.distance_to(global_position)

	if path_follow:
		path_follow.get_children()[0].update_position = true
		path_follow.get_children()[0].update_rotation = true
		path_follow.get_children()[0].remote_path = get_path()

func _process(delta):
	animation.flip_h = direction == Global.LEFT
	if follower:
		follower.direction = direction


func update_progress(progress: float) -> void:
	if path_follow:
		path_follow.progress = progress
		if follower:
			follower.update_progress(path_follow.progress - distance_to_follower)
