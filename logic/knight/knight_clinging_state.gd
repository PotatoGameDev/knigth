extends KnightState
class_name ClingingState

@export var gravity_coefficient := 0.2

var snapped_already := false

func enter(ownr, params: Dictionary = {}) -> void:
	ownr.animation.play("cling")
	ownr.velocity = Vector2.ZERO

	ownr.current_jump = 0

	if ownr.can_cling_right():
		ownr.direction = Global.RIGHT
	elif ownr.can_cling_left():
		ownr.direction = Global.LEFT
	ownr.animation.flip_h = ownr.direction == Global.LEFT

	snapped_already = false

func update(ownr: Knight, delta: float) -> void:
	if ownr.queued_jump_timer > 0.0:
		ownr.change_state(ownr.jumping_state, {"forced_direction": -ownr.direction})
		return

func integrate_forces(ownr: Knight, state: PhysicsDirectBodyState2D) -> void:
	var delta = state.get_step()

	ownr.velocity += state.get_total_gravity() * gravity_coefficient * delta

	if not snapped_already:
		while not ownr.move_and_collide(Vector2(ownr.direction * ownr.speed * delta, 0.0)):
			pass
		snapped_already = true

	if not ownr.is_on_floor():
		if not ownr.can_cling_right() and not ownr.can_cling_left():
			ownr.change_state(ownr.falling_state)
			return
		ownr.jump_stamina_left -= delta * ownr.jump_stamina_depletion_multiplier
		ownr.jump_stamina_left = max(ownr.jump_stamina_left, 0.0)

		if ownr.jump_stamina_left <= 0.0:
			ownr.change_state(ownr.falling_state)
			return
	

func handle_input(ownr: Knight, event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		# TODO: Remove this if jump pushoff is cool
		if \
				(Input.is_action_pressed("left") and ownr.is_left()) \
				or (Input.is_action_pressed("right") and ownr.is_right()) \
				or Input.is_action_pressed("up"):
			ownr.change_state(ownr.jumping_state)
			return
		else:
			ownr.change_state(ownr.jumping_state, {"forced_direction": -ownr.direction})
			return
	if event.is_action_pressed("smash"):
		if ownr.is_on_floor():
			ownr.change_state(ownr.idle_state)
			return
		else:
			ownr.change_state(ownr.smashing_state)
			return
	if (event.is_action_pressed("left") and ownr.is_right()) or (event.is_action_pressed("right") and ownr.is_left()):
		ownr.change_state(ownr.falling_state)
		return

	# TODO: Maybe merge with the above?:
	if event.is_action_pressed("down"):
		if (!ownr.is_left() or ownr.movement >= 0.0) and (!ownr.is_right() or ownr.movement <= 0.0):
			ownr.change_state(ownr.falling_state)
			return


func exit(ownr) -> void:
	ownr.cling_blocker = true
	ownr.coyote_timer = ownr.max_coyote_time
