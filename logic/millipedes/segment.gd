# segment.gd
extends AnimatableBody2D

@export var animation_delay := 0
@export var follower : Node2D = null

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

var direction := 1.0

func _ready() -> void:
	animation.play("walking")
	# get the animation length in godot frames
	var frames_count = animation.sprite_frames.get_frame_count(animation.animation)
	animation.frame += animation_delay % frames_count

func _process(delta):
	animation.flip_h = direction == Global.LEFT
	if follower:
		follower.direction = direction
