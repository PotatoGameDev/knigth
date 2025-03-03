# segment.gd
extends StaticBody2D

@export var animation_delay := 0
@export var path_follow : PathFollow2D = null
@export var controlling_bone : Bone2D = null

@export var v_offset : float = 0
@export var v_offset_scale : float = 1

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var remote_transform_for_controlling_bone: RemoteTransform2D = $RemoteTransform2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var friction := 0.3

var base_v_offset : float

func _ready() -> void:
	animation.play("walking")
	# get the animation length in godot frames
	var frames_count = animation.sprite_frames.get_frame_count(animation.animation)
	animation.frame += animation_delay % frames_count

	remote_transform_for_controlling_bone.remote_path = controlling_bone.get_path()

	base_v_offset = path_follow.v_offset

func get_friction() -> float:
	return friction

func _on_ritter_detector_body_entered(body:Node2D):
	if body is Knight:
		animation_player.play("bounce")
	
func _process(delta):
	path_follow.v_offset = base_v_offset + v_offset * v_offset_scale


func _on_ritter_detector_body_exited(body):
	if body is Knight:
		if v_offset > 0:
			body.replace_force(Vector2(0, -v_offset * 15000))
