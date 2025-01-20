extends KnightState
class_name RunningState 

@export var step_animation_speed_min := 0.8
var is_stepping := false

func enter(ownr: Knight, params: Dictionary = {}) -> void:
	if ownr.queued_jump_timer > 0.0:
		ownr.change_state(ownr.jumping_state)
		return
	ownr.animation.play("run")
	ownr.cling_blocker = true 
	
	is_stepping = false

func integrate_forces(ownr: Knight, state: PhysicsDirectBodyState2D) -> void:
	var delta = state.get_step()

	ownr.velocity.x = ownr.speed * ownr.movement

	if is_stepping:
		ownr.velocity.y = -max(ownr.step_speed_min, ownr.step_speed * -Input.get_axis("up", "down"))
		ownr.animation.speed_scale = -Input.get_axis("up", "down") + step_animation_speed_min
	else:
		ownr.animation.speed_scale = 1.0
	
	# ownr.move_and_slide()
	
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

	if not ownr.is_on_floor() and not is_stepping:
		ownr.change_state(ownr.falling_state)
		return
	
func handle_input(ownr: Knight, event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		ownr.change_state(ownr.jumping_state)
		return

func exit(ownr) -> void:
	ownr.coyote_timer = ownr.max_coyote_time
	ownr.animation.speed_scale = 1.0

	ownr.constant_force = Vector2.ZERO

func take_damage(ownr: Knight, damage: int, direction: Vector2) -> void:
	ownr.health -= damage
	ownr.change_state(ownr.pushback_state, {"direction": direction})
	return
