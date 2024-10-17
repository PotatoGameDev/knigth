# The player's idle state.
extends Node
class_name IdleState 

func enter(ownr) -> void:
	ownr.animation.play("idle")
	ownr.velocity = Vector2.ZERO

func update(_ownr, _delta: float) -> void:
	pass 

func handle_input(ownr: Knight) -> void:
	if !ownr.is_on_floor():
		ownr.change_state(ownr.falling_state)
	elif Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		ownr.change_state(ownr.running_state)
	elif Input.is_action_just_pressed("jump"):
		ownr.change_state(ownr.jumping_state)

func exit(_ownr) -> void:
	pass
