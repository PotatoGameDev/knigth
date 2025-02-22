extends Node2D
class_name Millipedes

@export var segments : Array[Node2D] = []
@export var distance_to_follower : float = 8.0
@export var speed := 100.0

@onready var skeleton: Skeleton2D = $Skeleton2D

func _on_antenna_ritter_detected():
	pass

var direction := Global.RIGHT
var head_index := 0

func _ready() -> void:
	head_index = 15

	stuff()

func stuff():
	for i in range(0, segments.size()):
		var segment = segments[i]
		segment.remote_transform_for_controlling_bone.update_position = head_index == i
		segment.remote_transform_for_controlling_bone.update_rotation = head_index == i

		# for everything that's before the head, we enable bone controls
		for c in segment.controlling_bone.get_children():
			if c is RemoteTransform2D:
				c.update_position = i < head_index
				c.update_rotation = i < head_index
				break

	for i in range(segments.size()):
		var segment = segments[i]
		if segment.path_follow:
			segment.path_follow.get_children()[0].update_position = i >= head_index
			segment.path_follow.get_children()[0].update_rotation = i >= head_index

	# iterate over bones in skeleton and apply rest
	for i in range(head_index, skeleton.get_bone_count()):
		var bone = skeleton.get_bone(i)
		bone.apply_rest()

func _process(delta):
	var current_progress = 0.0

	for i in range(0, segments.size()):
		var segment = segments[i]
		segment.animation.flip_h = direction == Global.LEFT

		if i == 0:
			if segment.path_follow:
				segment.path_follow.progress += delta * speed * direction
				current_progress = segment.path_follow.progress
		else:
			current_progress -= distance_to_follower * direction
			segment.path_follow.progress = current_progress
	
	if Input.is_key_pressed(KEY_0):
		attack_mode()
	elif Input.is_key_pressed(KEY_6):
		follow_mode()

func attack_mode() -> void:
	head_index = 15
	stuff()

func follow_mode() -> void:
	head_index = 0
	stuff()
