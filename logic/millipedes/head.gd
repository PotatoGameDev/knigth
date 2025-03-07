# head.gd
extends AnimatableBody2D
class_name MillipedesHead

@onready var animation: Sprite2D = $Sprite2D
@export var path_follow : PathFollow2D = null
@export var controlling_bone : Bone2D = null
@export var friction := 0.3

@onready var remote_transform_for_controlling_bone: RemoteTransform2D = $BoneController

func _ready() -> void:
	remote_transform_for_controlling_bone.remote_path = controlling_bone.get_path()

func get_friction() -> float:
	return friction

