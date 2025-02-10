# segment.gd
extends AnimatableBody2D

@export var animation_delay := 0
@export var follower : Node2D = null

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D

var direction := 1.0

func _ready() -> void:
	animation.play("walking")
	animation.frame += animation_delay

func _process(delta):
	animation.flip_h = direction == Global.LEFT
	if follower:
		follower.direction = direction
