# The player's jumping state.
extends Node
class_name JumpingState 

var movement := 0.0

func enter(ownr) -> void:
	ownr.animation.play("jump")
	ownr.velocity.y = -ownr.jump_force
	ownr.jump_timer = 0.0

func update(ownr: Knight, delta: float) -> void:
	if ownr.jump_timer < ownr.jump_hold_time:
		ownr.jump_timer += delta
		ownr.velocity.y = -ownr.jump_force
	else:
		ownr.change_state(ownr.falling_state)
		return

	if not ownr.is_on_floor():
		ownr.velocity.y += ownr.gravity * delta

	if ownr.velocity.y > ownr.max_fall_speed:
		ownr.velocity.y = ownr.max_fall_speed

	ownr.velocity.x = movement * ownr.speed

func handle_input(ownr: Knight) -> void:
	movement = Input.get_action_strength("right") - Input.get_action_strength("left")
	if movement != 0:
		ownr.direction = movement

	if !Input.is_action_pressed("jump"):
		ownr.change_state(ownr.falling_state)

	ownr.animation.flip_h = ownr.direction == -1

func exit(_ownr) -> void:
	pass

