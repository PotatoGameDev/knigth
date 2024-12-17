extends KnightState
class_name FallingState 

func enter(ownr, params: Dictionary = {}) -> void:
	if not ownr.is_bouncing:
		ownr.animation.play("fall")

func physics_update(ownr: Knight, delta: float) -> void:
	var last_speed = -ownr.velocity.y

	ownr.move_and_slide()
	
	ownr.enemy_smash_sensor.target_position = ownr.velocity * delta
	ownr.enemy_smash_sensor.force_update_transform()

	if ownr.enemy_smash_sensor.is_colliding():
		var smashed = false
		var min_enemy_normal = Vector2.INF
		var min_enemy_distance = INF
		for e in range(ownr.enemy_smash_sensor.get_collision_count()):
			var enemy = ownr.enemy_smash_sensor.get_collider(e)
			var enemy_normal = ownr.enemy_smash_sensor.get_collision_normal(e)
			if enemy is Zombi and enemy.is_alive():
				enemy.take_damage(ownr.strength * -last_speed * ownr.smash_speed_damage_factor)
				smashed = true
				if enemy_normal.length() < min_enemy_distance:
					min_enemy_distance = enemy_normal.length()
					min_enemy_normal = enemy_normal
		if smashed:
			ownr.global_position -= min_enemy_normal
			ownr.change_state(ownr.stomping_state)
			ownr.bounce_power = 1.0
			return

	if ownr.is_on_floor():
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

		ownr.velocity.y += Global.gravity * delta
		ownr.velocity.x = ownr.movement * ownr.speed

	if ownr.velocity.y > ownr.max_fall_speed:
		ownr.velocity.y = ownr.max_fall_speed
	
	ownr.coyote_timer -= delta

func handle_input(ownr: Knight, event: InputEvent) -> void:
	if (Input.is_action_pressed("left") and ownr.is_left()) or (Input.is_action_pressed("right") and ownr.is_right()):
		ownr.cling_blocker = false
		# TODO: I thing we need to copy the stuff from jumping state here
	elif event.is_action_pressed("jump") and ownr.coyote_timer > 0.0:
		ownr.change_state(ownr.jumping_state)
		return

	if event.is_action_pressed("smash"):
		ownr.change_state(ownr.smashing_state)
		return

func exit(ownr) -> void:
	ownr.velocity.y = 0
	ownr.enemy_smash_sensor.target_position = Vector2.ZERO
