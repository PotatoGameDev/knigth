# The player's jumping state.
extends Node
class_name JumpingState 

@export var jump_force := 100.0
@export var jump_speed := 100.0
@export var air_movement_speed := 30.0
var force_left := 0.0

func enter(ownr) -> void:
	ownr.animation.play("jump")
	force_left = jump_force

func update(ownr: Knight, delta: float) -> void:
	if force_left > 0.0 and Input.is_action_pressed("jump"):
		ownr.velocity.y = -(ownr.GRAVITY * delta + force_left)
		ownr.velocity.x = ownr.direction * air_movement_speed
		force_left -= jump_speed * delta
	else:
		ownr.change_state(ownr.falling_state)
		return

func handle_input(ownr: Knight) -> void:
	if Input.is_action_pressed("left"):
		ownr.direction = -1
	elif Input.is_action_pressed("right"):
		ownr.direction = 1
	else:
		ownr.direction = 0

	ownr.animation.flip_h = ownr.direction == -1

func exit(_ownr) -> void:
	force_left = 0.0


