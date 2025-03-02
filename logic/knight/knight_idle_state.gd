extends KnightState 
class_name IdleState 

# IMPORTANT: Do not enter this state if the player should go into "running" state instead.
func enter(ownr, _params: Dictionary = {}) -> void:
	if ownr.queued_jump_timer > 0.0:
		ownr.current_jump = 0
		ownr.change_state(ownr.jumping_state)
		return
	ownr.animation.play("idle")
	# ownr.velocity = Vector2.ZERO

	ownr.current_jump = 0

	ownr.cling_blocker = true 

	ownr.potential_energy = 0.0

func update(_ownr: Knight, _delta: float) -> void:
	pass

func physics_update(ownr: Knight, delta: float) -> void:
	var floor_friction = ownr.get_floor_friction()
	ownr.velocity.x *= 1.0 - floor_friction

	ownr.move_and_slide()

	ownr.jump_stamina_left += delta * ownr.jump_stamina_depletion_multiplier
	if ownr.jump_stamina_left > ownr.max_stamina:
		ownr.jump_stamina_left = ownr.max_stamina

	if !ownr.is_touching_floor():
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
	
func exit(ownr) -> void:
	ownr.coyote_timer = ownr.max_coyote_time

func take_damage(ownr: Knight, damage: int, direction: Vector2) -> void:
	ownr.health -= damage
	ownr.change_state(ownr.pushback_state, {"direction": direction})
	return
