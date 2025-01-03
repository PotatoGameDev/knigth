extends KnightState
class_name JumpingState 

func enter(ownr, params: Dictionary = {}) -> void:
	if not ownr.is_bouncing:
		ownr.animation.play("jump")

	ownr.velocity.y = -ownr.jump_force
	ownr.jump_timer = 0.0
	ownr.coyote_timer = 0.0
	ownr.cling_blocker = true

func update(ownr: Knight, delta: float) -> void:
	pass

func physics_update(ownr: Knight, delta: float) -> void:
	ownr.velocity.x = ownr.movement * ownr.speed

	ownr.jump_slip()

	if ownr.jump_timer < ownr.jump_hold_time:
		ownr.jump_timer += delta
		ownr.velocity.y = -ownr.jump_force
	else:
		ownr.change_state(ownr.falling_state)
		return
	
	if not ownr.is_on_floor():
		ownr.velocity.y += Global.gravity * delta
		ownr.jump_stamina_left -= delta * ownr.jump_stamina_depletion_multiplier
		ownr.jump_stamina_left = max(ownr.jump_stamina_left, 0.0)

	ownr.move_and_slide()

	if (Input.is_action_pressed("left") and ownr.is_left()) or (Input.is_action_pressed("right") and ownr.is_right()):
		ownr.cling_blocker = false

	if not can_cling(ownr):
		ownr.cling_blocker = false
	else:
		if \
		not ownr.cling_blocker \
		and not ownr.is_on_floor() \
		and not Input.is_action_pressed("up"): # This is to prevent the player from clinging immediately after jumping
			if ownr.jump_stamina_left > 0.0 and (ownr.can_cling_left() and ownr.is_left()) or (ownr.can_cling_right() and ownr.is_right()):
				ownr.change_state(ownr.clinging_state)
				return

	if not Input.is_action_pressed("jump"):
		ownr.change_state(ownr.falling_state)
		return

func can_cling(ownr: Knight) -> bool:
	#https://github.com/godotengine/godot/issues/76756
	# TODO: This is a workaround for the above issue is to NOT TRUST the is_on_wall() function
	#return ownr.is_on_wall() and (ownr.can_cling_left() or ownr.can_cling_right())
	return ownr.can_cling_left() or ownr.can_cling_right()

func handle_input(ownr: Knight, event: InputEvent) -> void:
	if event.is_action_pressed("smash"):
		ownr.change_state(ownr.smashing_state)
		return

