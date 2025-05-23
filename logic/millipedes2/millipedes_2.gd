extends Node2D
class_name MillipedesEnhancedEdition

enum State {
	FOLLOW_PATH,
	ATTACK,
	CURL,
}

var current_state := State.FOLLOW_PATH
var next_state = null

var transition := false


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var skeleton: Skeleton2D = $Skeleton2D

var state_funcs := {
	State.FOLLOW_PATH: follow_path_process,
	State.ATTACK: attack_process,
	State.CURL: curl_process,
}

func _ready() -> void:
	pass

func _process(delta: float) -> void:

	if transition:
		return

	state_funcs[current_state].call(delta)

	if next_state != null:
		current_state = next_state
		next_state = null

func animation_ended() -> void:
	transition = false


# State functions

func follow_path_process(delta: float) -> void:
	if Input.is_key_pressed(KEY_B):
		next_state = State.ATTACK
		animation_player.play("curl")		
		print("playing curl")
		transition = true
		return

func attack_process(delta: float) -> void:
	if Input.is_key_pressed(KEY_B):
		next_state = State.FOLLOW_PATH
		animation_player.play("attack")		
		transition = true
		print("playing attack")
		return

func curl_process(delta: float) -> void:
	pass

