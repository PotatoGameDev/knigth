extends Node
class_name RunningState 

@export var step_animation_speed_min := 0.8
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
	pass

func physics_update(ownr: Knight, delta: float) -> void:
	ownr.velocity.x = ownr.speed * ownr.movement
	ownr.coyote_timer = ownr.max_coyote_time

	if is_stepping:
		ownr.velocity.y = -max(ownr.step_speed_min, ownr.step_speed * -Input.get_axis("up", "down"))
		ownr.animation.speed_scale = -Input.get_axis("up", "down") + step_animation_speed_min
		print(ownr.animation.speed_scale)
	
	ownr.move_and_slide()
	
	# TODO: Here is a fun idea: Move repeating logic to ownr, and just set flags, like deplets_stamina.
	ownr.jump_stamina_left += delta * ownr.jump_stamina_depletion_multiplier
	if ownr.jump_stamina_left > ownr.stamina:
		ownr.jump_stamina_left = ownr.stamina
	
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

func exit(_ownr) -> void:
	pass
