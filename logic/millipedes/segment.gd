# segment.gd
extends AnimatableBody2D

@export var animation_delay := 0
@export var path_follow : PathFollow2D = null
@export var controlling_bone : Bone2D = null

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var remote_transform_for_controlling_bone: RemoteTransform2D = $RemoteTransform2D

var friction := 0.3

func _ready() -> void:
	animation.play("walking")
	# get the animation length in godot frames
	var frames_count = animation.sprite_frames.get_frame_count(animation.animation)
	animation.frame += animation_delay % frames_count

	remote_transform_for_controlling_bone.remote_path = controlling_bone.get_path()

func get_friction() -> float:
	return friction
