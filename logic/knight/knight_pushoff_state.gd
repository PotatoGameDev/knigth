extends Node
class_name PushOffState

var forced_direction := 0

func enter(ownr) -> void:
	ownr.velocity.y = -ownr.pushoff_force
	ownr.cling_pushoff_timer = 0.0
	ownr.coyote_timer = 0.0
	ownr.cling_blocker = true
	forced_direction = -ownr.direction

func update(ownr: Knight, delta: float) -> void:
	if ownr.cling_pushoff_timer < ownr.cling_pushoff_time: # TODO: Rename, this is asking for a bug
		if ownr.wallClingSensorRight.is_colliding() || ownr.wallClingSensorLeft.is_colliding():
			if not ownr.cling_blocker:
				ownr.change_state(ownr.clinging_state)
				return
		else:
			ownr.cling_blocker = false

		ownr.cling_pushoff_timer += delta
		ownr.velocity.y = -ownr.jump_force
	else:
		if Input.is_action_pressed("jump"):
			ownr.change_state(ownr.jumping_state)
			return
		else:
			ownr.change_state(ownr.falling_state)
			return

	if not ownr.is_on_floor():
		ownr.velocity.y += ownr.gravity * delta

	# Horizontal User Control
	# Forced to move left or right, depending on the direction
	ownr.velocity.x = forced_direction * ownr.speed

	# Jump Slip
	if ownr.jumpRayLeftOuter.is_colliding() and not ownr.jumpRayLeftInner.is_colliding():
		ownr.velocity.x += ownr.speed
	elif ownr.jumpRayRightOuter.is_colliding() and not ownr.jumpRayRightInner.is_colliding():
		ownr.velocity.x -= ownr.speed


func handle_input(ownr: Knight) -> void:
	pass

func exit(_ownr) -> void:
	pass
