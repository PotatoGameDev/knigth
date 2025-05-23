# segment.gd
extends AnimatedSprite2D
class_name SegmentEnhancedEdition

@export var animation_delay := 0
@export var path_follow : PathFollow2D = null

@export var v_offset : float = 0
@export var v_offset_scale : float = 1

@onready var animation_player: AnimationPlayer = $AnimationPlayer

var friction := 0.3

var base_v_offset : float

func _ready() -> void:
	#play("walking")
	# get the animation length in godot frames
	var frames_count = sprite_frames.get_frame_count(animation)
	frame += animation_delay % frames_count

	if path_follow:
		base_v_offset = path_follow.v_offset

func get_friction() -> float:
	return friction

func _on_ritter_detector_body_entered(body:Node2D):
	if body is Knight:
		animation_player.play("bounce")
	
func _process(delta):
	if path_follow:
		path_follow.v_offset = base_v_offset + v_offset * v_offset_scale

func _on_ritter_detector_body_exited(body):
	if body is Knight:
		if v_offset > 0:
			body.add_force(Vector2(0, -v_offset * 15000))
