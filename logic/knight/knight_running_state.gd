# The player's running state.
extends Node
class_name RunningState 

var is_stepping := false

func enter(ownr: Knight) -> void:
	if ownr.queued_jump_timer > 0.0:
		ownr.change_state(ownr.jumping_state)
		return
	ownr.animation.play("run")
	ownr.is_bouncing = false
	ownr.cling_blocker = true 
	
	is_stepping = false

func update(ownr: Knight, delta: float) -> void:
	ownr.velocity.x = ownr.speed * ownr.movement
	ownr.coyote_timer = ownr.max_coyote_time

	if is_stepping:
		ownr.velocity.y = -ownr.step_speed
	
	ownr.move_and_slide()

	# TODO: Here is a fun idea: Move repeating logic to ownr, and just set flags, like deplets_stamina.
	ownr.jump_stamina_left += delta * ownr.jump_stamina_depletion_multiplier
	if ownr.jump_stamina_left > ownr.stamina:
		ownr.jump_stamina_left = ownr.stamina
	
func handle_input(ownr: Knight) -> void:
	if not Input.is_action_pressed("left") and not Input.is_action_pressed("right"):
		ownr.change_state(ownr.idle_state)
		return

	if ownr.can_step_left() or ownr.can_step_right():
		is_stepping = true
		ownr.animation.play("step")
	else:
		is_stepping = false
		ownr.animation.play("run")

	if not ownr.is_on_floor() and not is_stepping:
		ownr.change_state(ownr.falling_state)
		return
	
	if ownr.movement != 0.0:
		ownr.direction = sign(ownr.movement)

	ownr.animation.flip_h = ownr.direction == -1

	if Input.is_action_just_pressed("jump"):
		ownr.change_state(ownr.jumping_state)


func exit(_ownr) -> void:
	pass
