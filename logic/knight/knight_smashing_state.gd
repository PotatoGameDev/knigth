extends KnightState
class_name SmashingState

@export var gravity_coefficient := 2.0
@export var min_controls_coefficient := 0.0
@export var max_controls_coefficient := 2.0 
@export var controls_coefficient_grow_rate := 20.0

var controls_coefficient := 0.0
const BOUNCE_POWER := 1.5

func enter(ownr, params: Dictionary = {}) -> void:
	ownr.animation.play("smash")
	controls_coefficient = min_controls_coefficient

func update(_ownr: Knight, _delta: float) -> void:
	pass

func physics_update(ownr: Knight, delta: float) -> void:
	var current_speed = -ownr.velocity.length()

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

	if ownr.is_on_floor():
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

	if Input.is_action_pressed("smash"):
		controls_coefficient = min(
			controls_coefficient + delta * controls_coefficient_grow_rate,
			max_controls_coefficient
			)
	else:
		controls_coefficient = min_controls_coefficient

	if ownr.is_on_floor():
 		# zero out queued jump timer to prevent double jumps when landing after smashing
		ownr.queued_jump_timer = 0.0

		if Input.is_action_pressed("left") or Input.is_action_pressed("right"):
			ownr.change_state(ownr.running_state)
			return
		else:
			ownr.change_state(ownr.idle_state)
			return
	else:
		ownr.velocity.y += Global.gravity * gravity_coefficient * delta
		var new_velocity_x = ownr.velocity.x + ownr.movement * controls_coefficient * ownr.acceleration * delta

		if abs(new_velocity_x) <= ownr.max_speed:
			ownr.velocity.x = new_velocity_x

	ownr.potential_energy -= ownr.velocity.y

func handle_input(ownr: Knight, event: InputEvent) -> void:
	if event.is_action_pressed("jump") and ownr.coyote_timer > 0.0:
		ownr.change_state(ownr.jumping_state)
		return
	
func exit(ownr: Knight) -> void:
	ownr.enemy_smashing_sensor.target_position = Vector2.ZERO
	
