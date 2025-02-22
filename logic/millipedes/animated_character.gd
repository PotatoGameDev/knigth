extends CharacterBody2D

@export var head : Node2D
@export var tail : Node2D

@onready var remote_transform : RemoteTransform2D = $RemoteTransform2D

var tail_offset : Vector2

func _ready():
	tail_offset = global_position - tail.global_position

func _process(delta):
	#velocity.y -= Global.gravity * delta
	#move_and_slide()
	pass

func enable():
	#global_position = tail.global_position + tail_offset
	#remote_transform.global_position = tail.global_position 
	#remote_transform.remote_path = tail.get_path()
	#remote_transform.update_position = true
	pass

