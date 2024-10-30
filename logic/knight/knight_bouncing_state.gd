# The player's jumping state.
extends Node
class_name BouncingState 

func enter(ownr) -> void:
	ownr.animation.play("bounce")
	ownr.velocity.y = -ownr.jump_force
	ownr.jump_timer = 0.0
	ownr.coyote_timer = 0.0
	ownr.is_bouncing = true

func update(ownr: Knight, delta: float) -> void:
	if ownr.jump_timer < 0.5 * ownr.jump_hold_time:
		ownr.jump_timer += delta
		ownr.velocity.y = -ownr.jump_force * ownr.bounce_power
	else:
		ownr.change_state(ownr.falling_state)
		return

	if not ownr.is_on_floor():
		ownr.velocity.y += ownr.gravity * delta

	# Horizontal User Control
	ownr.velocity.x = ownr.movement * ownr.speed

	# Jump Slip
	if ownr.jumpRayLeftOuter.is_colliding() and not ownr.jumpRayLeftInner.is_colliding():
		print("Jump Slip Right")
		ownr.velocity.x += ownr.speed
	elif ownr.jumpRayRightOuter.is_colliding() and not ownr.jumpRayRightInner.is_colliding():
		print("Jump Slip Left")
		ownr.velocity.x -= ownr.speed

func handle_input(ownr: Knight) -> void:
	if ownr.movement != 0:
		ownr.direction = ownr.movement

	ownr.animation.flip_h = ownr.direction == -1

	if Input.is_action_just_pressed("smash"):
		ownr.change_state(ownr.smashing_state)
		return

func exit(_ownr) -> void:
	pass


