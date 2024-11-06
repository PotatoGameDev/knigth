extends Node
class_name IdleState 

func enter(ownr) -> void:
	if ownr.queued_jump_timer > 0.0:
		ownr.change_state(ownr.jumping_state)
		return
	ownr.animation.play("idle")
	ownr.velocity = Vector2.ZERO

	ownr.is_bouncing = false
	ownr.cling_blocker = true 

func update(ownr, _delta: float) -> void:
	ownr.coyote_timer = ownr.max_coyote_time

func handle_input(ownr: Knight) -> void:
	if !ownr.is_on_floor():
		ownr.change_state(ownr.falling_state)
		return
	elif Input.is_action_just_pressed("jump"):
		ownr.change_state(ownr.jumping_state)
		return
	elif Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		ownr.change_state(ownr.running_state)
		return
	elif Input.is_action_pressed("smash"):
		# intentionally nothing
		pass

func exit(_ownr) -> void:
	pass
