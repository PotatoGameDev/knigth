# The player's running state.
extends Node
class_name RunningState 

func enter(ownr: Knight) -> void:
	ownr.animation.play("run")

func update(ownr: Knight, _delta: float) -> void:
	ownr.velocity.x = ownr.speed * ownr.direction

func handle_input(ownr: Knight) -> void:
	if !ownr.is_on_floor():
		ownr.change_state(ownr.falling_state)
	if !Input.is_action_pressed("left") and !Input.is_action_pressed("right"):
		ownr.change_state(ownr.idle_state)
	
	if Input.is_action_pressed("left"):
		ownr.direction = -1
	elif Input.is_action_pressed("right"):
		ownr.direction = 1
	ownr.animation.flip_h = ownr.direction == -1

	if Input.is_action_just_pressed("jump"):
		ownr.change_state(ownr.jumping_state)

func exit(_ownr) -> void:
	pass
