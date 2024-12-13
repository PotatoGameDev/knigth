extends Node
class_name IdleState 

func enter(ownr, params: Dictionary = {}) -> void:
	if ownr.queued_jump_timer > 0.0:
		ownr.change_state(ownr.jumping_state)
		return
	ownr.animation.play("idle")
	ownr.velocity = Vector2.ZERO

	ownr.is_bouncing = false
	ownr.cling_blocker = true 

func update(ownr: Knight, delta: float) -> void:
	pass

func physics_update(ownr: Knight, delta: float) -> void:
	ownr.move_and_slide()

	ownr.coyote_timer = ownr.max_coyote_time

	ownr.jump_stamina_left += delta * ownr.jump_stamina_depletion_multiplier
	if ownr.jump_stamina_left > ownr.stamina:
		ownr.jump_stamina_left = ownr.stamina

	if !ownr.is_on_floor():
		ownr.change_state(ownr.falling_state)
		return
	if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		ownr.change_state(ownr.running_state)
		return

	if Input.is_action_pressed("smash"):
		# intentionally nothing
		pass

func handle_input(ownr: Knight, event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		ownr.change_state(ownr.jumping_state)
		return
	

func exit(_ownr) -> void:
	pass
