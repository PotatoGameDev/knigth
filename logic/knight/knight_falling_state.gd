# The player's idle state.
extends Node
class_name FallingState 

func enter(ownr) -> void:
	if not ownr.is_bouncing:
		ownr.animation.play("fall")

func update(ownr: Knight, delta: float) -> void:
	if ownr.is_on_floor():
		if ownr.enemySmashSensor.is_colliding():
			var smashed = false
			for e in range(ownr.enemySmashSensor.get_collision_count()):
				var enemy = ownr.enemySmashSensor.get_collider(e)
				if enemy is Zombi and enemy.is_alive():
					enemy.take_damage(ownr.strength)
					smashed = true
			if smashed:
				ownr.change_state(ownr.stomping_state)
				ownr.bounce_power = 1.0
				return

		ownr.change_state(ownr.idle_state)
		return
	else:
		if ownr.can_cling_left() or ownr.can_cling_right():
			if not ownr.cling_blocker and ownr.jump_stamina_left > 0.0:
				ownr.change_state(ownr.clinging_state)
				return
		else:
			if not Input.is_action_pressed("jump"):
				ownr.cling_blocker = false

		ownr.velocity.y += ownr.gravity * delta
		ownr.velocity.x = ownr.movement * ownr.speed

	if ownr.velocity.y > ownr.max_fall_speed:
		ownr.velocity.y = ownr.max_fall_speed
	
	ownr.move_and_slide()
	
	ownr.coyote_timer -= delta

func handle_input(ownr: Knight) -> void:
	if ownr.movement != 0:
		ownr.direction = ownr.movement

	ownr.animation.flip_h = ownr.direction == -1

	if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
		ownr.cling_blocker = false

	if Input.is_action_just_pressed("jump") and ownr.coyote_timer > 0.0:
		ownr.change_state(ownr.jumping_state)
		return
	if Input.is_action_just_pressed("smash"):
		ownr.change_state(ownr.smashing_state)
		return
	
func exit(ownr) -> void:
	ownr.velocity.y = 0
