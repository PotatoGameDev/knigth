extends KnightState
class_name RunningState 

@export var step_animation_speed_min := 0.8
var is_stepping := false
var dyn_friction_factor := 0.1

func enter(ownr: Knight, _params: Dictionary = {}) -> void:
	ownr.current_jump = 0

	if ownr.queued_jump_timer > 0.0:
		ownr.change_state(ownr.jumping_state)
		return

	ownr.animation.play("run")
	ownr.cling_blocker = true 
	
	is_stepping = false

	ownr.potential_energy = 0.0

func physics_update(ownr: Knight, delta: float) -> void:
	var new_velocity_x = ownr.velocity.x + ownr.movement * ownr.acceleration * delta

	var floor_friction = ownr.get_floor_friction()
	new_velocity_x *= 1.0 - (floor_friction * dyn_friction_factor)

	if abs(new_velocity_x) <= ownr.max_speed:
		ownr.velocity.x = new_velocity_x

	if is_stepping:
		ownr.velocity.y = -max(ownr.step_speed_min, ownr.step_speed * -Input.get_axis("up", "down"))
		ownr.animation.speed_scale = -Input.get_axis("up", "down") + step_animation_speed_min
	else:
		ownr.animation.speed_scale = 1.0

	ownr.move_and_slide()
	
	# TODO: Check friction on enemies?
	
	# TODO: Here is a fun idea: Move repeating logic to ownr, and just set flags, like deplets_stamina.
	ownr.jump_stamina_left += delta * ownr.jump_stamina_depletion_multiplier
	if ownr.jump_stamina_left > ownr.max_stamina:
		ownr.jump_stamina_left = ownr.max_stamina
	
	if not Input.is_action_pressed("left") and not Input.is_action_pressed("right"):
		ownr.change_state(ownr.idle_state)
		return

	if ((ownr.can_step_left() and ownr.is_left()) or (ownr.can_step_right() and ownr.is_right())) and Input.is_action_pressed("up"):
		if not is_stepping:
			ownr.animation.play("step")
		is_stepping = true
	else:
		ownr.animation.play("run")
		is_stepping = false

	if not ownr.is_touching_floor() and not is_stepping:
		ownr.change_state(ownr.falling_state)
		return
	
func handle_input(ownr: Knight, event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		ownr.change_state(ownr.jumping_state)
		return

func exit(ownr) -> void:
	ownr.coyote_timer = ownr.max_coyote_time
	ownr.animation.speed_scale = 1.0

func take_damage(ownr: Knight, damage: int, direction: Vector2) -> void:
	ownr.health -= damage
	ownr.change_state(ownr.pushback_state, {"direction": direction})
	return
