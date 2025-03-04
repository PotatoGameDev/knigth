extends KnightState
class_name JumpingState 

# INFO: Jumping entails initial jump and upward movement afterwards.

var is_bouncing := false
var is_falling := false
var forced_direction := 0
var added_force := Vector2.ZERO

func _init():
	options.calculate_queued_jump_timer = false

func enter(ownr, params: Dictionary = {}) -> void:
	is_falling = false
	is_bouncing = false
	
	ownr.queued_jump_timer = 0.0

	if "bouncing" in params:
		is_bouncing = params["bouncing"]


	if "forced_direction" in params:
		forced_direction = params["forced_direction"]
		if forced_direction != 0.0:
			ownr.direction = forced_direction
		options.calculate_direction = forced_direction == 0.0
	else:
		options.calculate_direction = true 
		forced_direction = 0

	if is_bouncing:
		ownr.animation.play("bounce")
		# RULE: Bouncing resets jumps counter:
		ownr.current_jump = 0
	else:
		ownr.animation.play("jump")

	# RULE: Jumping increases jumps counter, bouncing too:
	ownr.current_jump += 1

	ownr.velocity.y = -ownr.jump_force
	ownr.jump_timer = 0.0
	ownr.coyote_timer = 0.0
	ownr.cling_blocker = true


func update(_ownr: Knight, _delta: float) -> void:
	if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		options.calculate_direction = true
		forced_direction = 0

func physics_update(ownr: Knight, delta: float) -> void:
	ownr.jump_slip(delta)

	var new_velocity_x
	if ownr.movement != 0.0 or options.calculate_direction:
		new_velocity_x = ownr.velocity.x + ownr.movement * ownr.acceleration * delta
	else:
		new_velocity_x = ownr.velocity.x + ownr.direction * ownr.acceleration * delta

	new_velocity_x *= 1.0 - ownr.air_drag

	if abs(new_velocity_x) <= ownr.max_speed:
		ownr.velocity.x = new_velocity_x

	if ownr.jump_timer < ownr.jump_hold_time:
		if not is_falling:
			ownr.jump_timer += delta
			ownr.velocity.y = -ownr.jump_force

			if added_force != Vector2.ZERO:
				var abs_added_force = added_force.abs()
				var sign_added_force = added_force.sign()

				var boost = abs_added_force.minf(500)

				ownr.velocity += boost * sign_added_force
				added_force -= boost * sign_added_force
		else:
			if ownr.velocity.y < -ownr.jump_force:
				ownr.velocity.y = -ownr.jump_force
	else:
		is_falling = true
	
	
	if not ownr.is_touching_floor():
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
		and not ownr.is_touching_floor() \
		and not Input.is_action_pressed("up"): # This is to prevent the player from clinging immediately after jumping
			if ownr.jump_stamina_left > 0.0 and (ownr.can_cling_left() and ownr.is_left()) or (ownr.can_cling_right() and ownr.is_right()):
				ownr.change_state(ownr.clinging_state)
				return

	if not Input.is_action_pressed("jump") and not Input.is_action_pressed("smash"):
		is_falling = true

	if is_falling and ownr.velocity.y >= 0.0:
		ownr.change_state(ownr.falling_state, {"bouncing": is_bouncing, "forced_direction": forced_direction})
		return


func can_cling(ownr: Knight) -> bool:
	#https://github.com/godotengine/godot/issues/76756
	# TODO: This is a workaround for the above issue is to NOT TRUST the is_on_wall() function
	#return ownr.is_on_wall() and (ownr.can_cling_left() or ownr.can_cling_right())
	return ownr.can_cling_left() or ownr.can_cling_right()

func handle_input(ownr: Knight, event: InputEvent) -> void:
	if event.is_action_pressed("smash") and ownr.can_smash():
		ownr.change_state(ownr.smashing_state)
		return

	if event.is_action_pressed("jump") and ownr.current_jump < ownr.max_jumps:
		ownr.change_state(ownr.jumping_state)
		return

func exit(_ownr: Knight) -> void:
	options.calculate_direction = true
	forced_direction = 0

func add_force(_ownr: Knight, _force: Vector2) -> void:
	print("Adding force state: ", _force)
	added_force = _force
