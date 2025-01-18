extends KnightState
class_name BouncingState 

func enter(ownr, params: Dictionary = {}) -> void:
	ownr.animation.play("bounce")
	ownr.velocity.y = -ownr.jump_force
	ownr.jump_timer = 0.0
	ownr.coyote_timer = 0.0
	ownr.is_bouncing = true

func update(ownr: Knight, delta: float) -> void:
	pass

func integrate_forces(ownr: Knight, state: PhysicsDirectBodyState2D) -> void:
	var delta = state.get_step()

	if ownr.jump_timer < 0.5 * ownr.jump_hold_time:
		ownr.jump_timer += delta
		ownr.velocity.y = -ownr.jump_force * ownr.bounce_power
	else:
		ownr.change_state(ownr.falling_state)
		return

	# Horizontal User Control
	ownr.velocity.x = ownr.movement * ownr.speed

	ownr.jump_slip()

func handle_input(ownr: Knight, event: InputEvent) -> void:
	if event.is_action_pressed("smash"):
		ownr.change_state(ownr.smashing_state)
		return

func exit(_ownr) -> void:
	pass


