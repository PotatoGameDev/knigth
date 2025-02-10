# head.gd
extends AnimatableBody2D

@onready var animation: Sprite2D = $Sprite2D
@export var follower : Node2D = null

var direction := Global.RIGHT

func _ready() -> void:
	pass

func _process(delta):
	animation.flip_h = direction == Global.LEFT
	follower.direction = direction
