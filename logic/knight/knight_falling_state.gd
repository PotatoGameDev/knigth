extends KnightState
class_name FallingState 

var is_bouncing := false
const BOUNCE_POWER := 1.0

func enter(ownr, params: Dictionary = {}) -> void:
	# INFO: This is by design. We allow the player to maintain inertia.
	# Gravity will pull them downwards anyway. Setting velocity to zero
	# will cause an invisible wall effect when jump ends.
	# ownr.velocity.y = 0.0

	is_bouncing = false
	if "bouncing" in params:
		is_bouncing = params["bouncing"]

	if "forced_direction" in params:
		var forced_direction = params["forced_direction"]
		if forced_direction != 0.0:
			ownr.direction = forced_direction
		
		options.calculate_direction = forced_direction == 0.0
	else:
		options.calculate_direction = true 

	if not is_bouncing:
		ownr.animation.play("fall")

func update(_ownr: Knight, _delta: float) -> void:
	if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		options.calculate_direction = true

func physics_update(ownr: Knight, delta: float) -> void:
	var current_speed = -ownr.velocity.length()
	var new_velocity_x
	if ownr.movement != 0.0 or options.calculate_direction:
		new_velocity_x = ownr.velocity.x + ownr.movement * ownr.acceleration * delta
	else:
		new_velocity_x = ownr.velocity.x + ownr.direction * ownr.acceleration * delta

	new_velocity_x *= 1.0 - ownr.air_drag

	if abs(new_velocity_x) <= ownr.max_speed:
		ownr.velocity.x = new_velocity_x

	ownr.enemy_smashing_sensor.target_position = ownr.velocity * delta
	ownr.enemy_smashing_sensor.force_update_transform()

	var smashed_enemy = null 
	if ownr.enemy_smashing_sensor.is_colliding():
		for e in range(ownr.enemy_smashing_sensor.get_collision_count()):
			var enemy = ownr.enemy_smashing_sensor.get_collider(e)
			if enemy is Zombi:
				smashed_enemy = enemy

		ownr.velocity = ownr.velocity * ownr.enemy_smashing_sensor.get_closest_collision_safe_fraction()

	ownr.move_and_slide()

	if ownr.is_touching_floor():
		var collision = ownr.get_last_slide_collision()
		if collision:
			var enemy = collision.get_collider()
			if enemy is Zombi:
				smashed_enemy = enemy

	if smashed_enemy:
		var damage = ownr.weight * -current_speed * ownr.smash_speed_damage_factor
		smashed_enemy.take_damage(max(damage, ownr.min_damage))
		ownr.bounce_power = BOUNCE_POWER
		ownr.change_state(ownr.stomping_state)
		return

	if ownr.is_touching_floor():
		if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
			ownr.change_state(ownr.running_state)
			return
		else:
			ownr.change_state(ownr.idle_state)
			return
	else:
		if (ownr.can_cling_left() and ownr.is_left()) or (ownr.can_cling_right() and ownr.is_right()):
			if not ownr.cling_blocker and ownr.jump_stamina_left > 0.0:
				ownr.change_state(ownr.clinging_state)
				return
		else:
			if not Input.is_action_pressed("jump"):
				ownr.cling_blocker = false

	ownr.coyote_timer -= delta

func handle_input(ownr: Knight, event: InputEvent) -> void:
	if (Input.is_action_pressed("left") and ownr.is_left()) or (Input.is_action_pressed("right") and ownr.is_right()):
		ownr.cling_blocker = false
		# TODO: I think we need to copy the stuff from jumping state here
	if event.is_action_pressed("jump") and (ownr.coyote_timer > 0.0 or ownr.current_jump < ownr.max_jumps):
		ownr.change_state(ownr.jumping_state)
		return

	if event.is_action_pressed("smash") and ownr.can_smash():
		ownr.change_state(ownr.smashing_state)
		return

func exit(ownr: Knight) -> void:
	options.calculate_direction = true
	ownr.enemy_smashing_sensor.target_position = Vector2.ZERO
