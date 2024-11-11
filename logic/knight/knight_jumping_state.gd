# The player's jumping state.
extends Node
class_name JumpingState 

func enter(ownr) -> void:
	if not ownr.is_bouncing:
		ownr.animation.play("jump")

	ownr.velocity.y = -ownr.jump_force
	ownr.jump_timer = 0.0
	ownr.coyote_timer = 0.0

func update(ownr: Knight, delta: float) -> void:

	if ownr.jump_timer < ownr.jump_hold_time:
		ownr.jump_timer += delta
		ownr.velocity.y = -ownr.jump_force
	else:
		ownr.change_state(ownr.falling_state)
		return

	if not ownr.is_on_floor():
		ownr.velocity.y += ownr.gravity * delta
		ownr.jump_stamina_left -= delta * ownr.jump_stamina_depletion_multiplier
		ownr.jump_stamina_left = max(ownr.jump_stamina_left, 0.0)

	ownr.move_and_slide()

	# Horizontal User Control
	if not ownr.cling_blocker and ownr.is_on_wall() and (Input.is_action_pressed("left") or Input.is_action_pressed("right")) and not ownr.is_on_floor():
		if ownr.jump_stamina_left > 0.0:
			ownr.change_state(ownr.clinging_state)
			return

	if not ownr.is_on_wall():
		ownr.velocity.x = ownr.movement * ownr.speed

	# Jump Slip
	if ownr.jumpRayLeftOuter.is_colliding() and not ownr.jumpRayLeftInner.is_colliding() and ownr.movement > 0:
		ownr.velocity.x += ownr.speed
	elif ownr.jumpRayRightOuter.is_colliding() and not ownr.jumpRayRightInner.is_colliding() and ownr.movement < 0:
		ownr.velocity.x -= ownr.speed

func handle_input(ownr: Knight) -> void:
	if ownr.movement != 0:
		ownr.direction = ownr.movement

	ownr.animation.flip_h = ownr.direction == -1

	if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right"):
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
