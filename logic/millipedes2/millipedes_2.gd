extends Node2D
class_name MillipedesEnhancedEdition

enum State {
	FOLLOW_PATH,
	ATTACK,
	CURL,
}

var segments : Array[Node2D];

var current_state = State.FOLLOW_PATH
var next_state = null

var wheel_enabled := true

var transition := false

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var skeleton: Skeleton2D = $Skeleton2D

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
	# Prepare segments list, soret by postfix
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
	if Input.is_key_pressed(KEY_B):
		next_state = State.CURL
		return

func attack_process(delta: float) -> void:
	pass

func curl_process(delta: float) -> void:
	if Input.is_key_pressed(KEY_B):
		next_state = State.FOLLOW_PATH

# State enter

func follow_path_enter() -> void:
	# TODO: change animation
	animation_player.play("attack")
	transition = true

func attack_enter() -> void:
	animation_player.play("attack")
	transition = true

func curl_enter() -> void:
	animation_player.play("curl")
	transition = true
	wheel_enabled = true

# State exit
func follow_path_exit() -> void:
	pass

func attack_exit() -> void:
	pass

func curl_exit() -> void:
	wheel_enabled = false

# other functions

func animation_ended() -> void:
	transition = false

	if wheel_enabled:
		wheelCollisionShape.global_position = segments[HEAD_INDEX].global_position
		wheelCollisionShape.rotation = segments[HEAD_INDEX].rotation
		wheelCollisionShape.disabled = false
		wheelRemoteTransform.update_position = true
		wheelRemoteTransform.update_rotation = true
		wheel.sleeping = false
		wheel.freeze = false
	else:
		wheelRemoteTransform.update_position = false
		wheelRemoteTransform.update_rotation = false
		wheelCollisionShape.disabled = true
		wheel.sleeping = true
		wheel.freeze = true
