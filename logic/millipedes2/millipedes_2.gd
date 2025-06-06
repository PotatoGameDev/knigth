extends Node2D
class_name MillipedesEnhancedEdition

enum State {
	FOLLOW_PATH,
	ATTACK,
	CURL,
}

var segments : Array[Node2D]
var path_follow_remote_transforms: Array[RemoteTransform2D]
var bone_remote_transforms: Array[RemoteTransform2D]

var current_state = null
var next_state = null

var transition := false

var direction := Global.RIGHT
var distance_to_follower := 8.0
var speed := 100.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var skeleton: Skeleton2D = $Skeleton2D
@onready var soupFabrik: SoupFABRIK = $SoupFabrik

@onready var wheel: RigidBody2D = $MilipedesWheel
@onready var wheelCollisionShape: CollisionShape2D = $MilipedesWheel/CollisionShape2D
@onready var wheelRemoteTransform: RemoteTransform2D = $MilipedesWheel/RemoteTransform2D

const HEAD_INDEX := 0

var state_funcs := {
	State.FOLLOW_PATH: follow_path_process,
	State.ATTACK: attack_process,
	State.CURL: curl_process,
}

var enter_state_funcs := {
	State.FOLLOW_PATH: follow_path_enter,
	State.ATTACK: attack_enter,
	State.CURL: curl_enter
}

var exit_state_funcs := {
	State.FOLLOW_PATH: follow_path_exit,
	State.ATTACK: attack_exit,
	State.CURL: curl_exit 
}

func _ready() -> void:
	# Prepare segments list, sorted by postfix
	var segments_map := Dictionary()

	for s in $Segments.get_children():
		if s.name.begins_with("Head"):
			segments_map[HEAD_INDEX] = s
			continue
		if not s.name.begins_with("Segment"):
			continue
		var segment_id = s.name.trim_prefix("Segment").to_int()
		segments_map[segment_id] = s

	var segment_ids = segments_map.keys()
	segment_ids.sort()

	segments = []
	for segment_id in segment_ids:
		segments.append(segments_map[segment_id])

	# Prepare path follows, correlated to segments
	var path_follow_remote_transforms_map = {}
	for p in get_tree().get_nodes_in_group("path_follow_remote_transforms") as Array[RemoteTransform2D]:
		if p.get_parent().name == "PathFollowHead":
			p.remote_path = p.get_path_to(segments[HEAD_INDEX])
			path_follow_remote_transforms_map[HEAD_INDEX] = p
		else:
			var segment_id = p.get_parent().name.trim_prefix("PathFollow").to_int()
			p.remote_path = p.get_path_to(segments[segment_id])
			path_follow_remote_transforms_map[segment_id] = p

	var path_follow_ids = path_follow_remote_transforms_map.keys()
	path_follow_ids.sort()

	path_follow_remote_transforms = []
	for path_follow_id in path_follow_ids:
		path_follow_remote_transforms.append(path_follow_remote_transforms_map[path_follow_id])
		segments[path_follow_id].path_follow = path_follow_remote_transforms_map[path_follow_id].get_parent()

	# Prepare bone remote transforms, correlated to segments
	var bone_remote_transforms_map = {}
	for p in get_tree().get_nodes_in_group("bone_remote_transforms") as Array[RemoteTransform2D]:
		if p.name == "Head2RT":
			#p.remote_path = p.get_path_to(segments[HEAD_INDEX])
			bone_remote_transforms_map[HEAD_INDEX] = p
		else:
			var segment_id = p.name.trim_prefix("Segment").trim_suffix("RT").to_int()
			bone_remote_transforms_map[segment_id] = p
	
	var bone_remote_transform_ids = bone_remote_transforms_map.keys()
	bone_remote_transform_ids.sort()

	bone_remote_transforms = []
	for bone_remote_transform_id in bone_remote_transform_ids:
		bone_remote_transforms.append(bone_remote_transforms_map[bone_remote_transform_id])

	# Set initial state
	next_state = State.FOLLOW_PATH

func _process(delta: float) -> void:
	if next_state != null:
		if current_state != null:
			exit_state_funcs[current_state].call()
			current_state = null

		if transition:
			return

		enter_state_funcs[next_state].call()
		current_state = next_state
		next_state = null

	if transition:
		return

	state_funcs[current_state].call(delta)

# =============================================================================
# State functions

# State process

func follow_path_process(delta: float) -> void:
	var current_progress = 0.0

	for i in range(segments.size()):
		var segment = segments[i]
		if segment.path_follow:
			if i == HEAD_INDEX:
				segment.path_follow.progress += delta * speed * direction
				current_progress = segment.path_follow.progress
			else:
				current_progress -= distance_to_follower * direction
				segment.path_follow.progress = current_progress

	if Input.is_key_pressed(KEY_B):
		next_state = State.CURL


func attack_process(delta: float) -> void:
	if Global.ritter != null:
		$Target.global_position = Global.ritter.global_position

func curl_process(delta: float) -> void:
	if Input.is_key_pressed(KEY_B):
		next_state = State.ATTACK

# State enter

func follow_path_enter() -> void:
	# Most probably, we will never need to enter this state more than once.
	# The animation to set the segments in the correct positions
	# would be too complex, due to the way the segments follow the path
	# using offsets.
	set_bone_controls_enabled(false)

	set_path_follow_enabled(true)

func attack_enter() -> void:
	animation_player.play("attack")
	transition = true
	
	for bone_remote_transform in bone_remote_transforms:
		var bone = bone_remote_transform.get_parent()
		bone.transform_mode = SoupBone2D.TransformMode.RECORDING_TARGET
	
func curl_enter() -> void:
	skeleton.global_position = segments[-1].global_position
	skeleton.rotation = segments[-1].rotation

	set_bone_controls_enabled(true)
	animation_player.play("curl")
	transition = true

# State exit
func follow_path_exit() -> void:
	set_path_follow_enabled(false)

func attack_exit() -> void:
	pass

func curl_exit() -> void:
	set_wheel_enabled(false)

# other functions

func animation_ended(wheel_enabled: bool, fabrik_enabled: bool, bones_enabled: bool) -> void:
	transition = false

	if wheel_enabled:
		# Sequence is needed to avoid glitches
		# First we update the skeleton position, because it's being moved by the remote transform
		# Then we reset the skeletons first child, which controls the rest through the bones.
		# Finally we move the wheel to the skeleton position, to keep things in sync.

		skeleton.global_position = segments[-1].global_position
		segments[-1].global_position = skeleton.global_position

		wheel.global_position = skeleton.global_position
		wheel.rotation = skeleton.rotation

		# Now we can enable the wheel
		set_wheel_enabled(true)
		
		# Wait for the remote transform to update 
		# so we move the collider to the right position
		await get_tree().process_frame

		# Finally, move the collider to the skeleton position
		wheelCollisionShape.global_position = segments[HEAD_INDEX].global_position
		wheelCollisionShape.rotation = segments[HEAD_INDEX].rotation
		# It should be the perfection now!
	else:
		set_wheel_enabled(false)
	
	if fabrik_enabled:
		soupFabrik.enabled = true
		for bone_remote_transform in bone_remote_transforms:
			var bone = bone_remote_transform.get_parent()
			bone.transform_mode = SoupBone2D.TransformMode.IK
	else:
		soupFabrik.enabled = false
		for bone_remote_transform in bone_remote_transforms:
			var bone = bone_remote_transform.get_parent()
			bone.transform_mode = SoupBone2D.TransformMode.MANUAL

	set_bone_controls_enabled(bones_enabled)

func set_path_follow_enabled(enabled: bool):
	for path_follow_remote_transform in path_follow_remote_transforms:
		path_follow_remote_transform.update_position = enabled
		path_follow_remote_transform.update_rotation = enabled
		path_follow_remote_transform.update_scale = enabled

func set_bone_controls_enabled(enabled: bool):
	for bone_remote_transform in bone_remote_transforms:
		bone_remote_transform.update_position = enabled
		bone_remote_transform.update_rotation = enabled
		bone_remote_transform.update_scale = enabled

func set_wheel_enabled(enabled: bool):
	wheelRemoteTransform.update_position = enabled
	wheelRemoteTransform.update_rotation = enabled
	wheelCollisionShape.disabled = not enabled
	wheel.sleeping = not enabled
	wheel.freeze = not enabled

# =============================================================================
