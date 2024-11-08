# The player's jumping state.
extends Node
class_name JumpingState 

func enter(ownr) -> void:
	if not ownr.is_bouncing:
		ownr.animation.play("jump")

	ownr.velocity.y = -ownr.jump_force
	ownr.jump_timer = 0.0
	ownr.coyote_timer = 0.0

	ownr.cling_blocker = true

func update(ownr: Knight, delta: float) -> void:
	if ownr.jump_timer < ownr.jump_hold_time:
		if ownr.wallClingSensorRight.is_colliding() || ownr.wallClingSensorLeft.is_colliding():
			if not ownr.cling_blocker and ownr.jump_stamina_left > 0.0:
				ownr.change_state(ownr.clinging_state)
				return
		else:
			if not Input.is_action_pressed("jump"):
				ownr.cling_blocker = false

		ownr.jump_timer += delta
		ownr.velocity.y = -ownr.jump_force
	else:
		ownr.change_state(ownr.falling_state)
		return

	if not ownr.is_on_floor():
		ownr.velocity.y += ownr.gravity * delta
		ownr.jump_stamina_left -= delta * ownr.jump_stamina_depletion_multiplier
		ownr.jump_stamina_left = max(ownr.jump_stamina_left, 0.0)

	# Horizontal User Control
	ownr.velocity.x = ownr.movement * ownr.speed

	# Jump Slip
	if ownr.jumpRayLeftOuter.is_colliding() and not ownr.jumpRayLeftInner.is_colliding():
		ownr.velocity.x += ownr.speed
	elif ownr.jumpRayRightOuter.is_colliding() and not ownr.jumpRayRightInner.is_colliding():
		ownr.velocity.x -= ownr.speed


func handle_input(ownr: Knight) -> void:
	if ownr.movement != 0:
		ownr.direction = ownr.movement

	ownr.animation.flip_h = ownr.direction == -1

	if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		if ownr.last_on_floor_timer > ownr.jump_cling_debounce_time:
			ownr.cling_blocker = false

	if not Input.is_action_pressed("jump"):
		if Input.is_action_just_pressed("smash"):
			ownr.change_state(ownr.smashing_state)
			return
		else:
			ownr.change_state(ownr.falling_state)
			return

func exit(_ownr) -> void:
	pass
