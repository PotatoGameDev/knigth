# The player's running state.
extends Node
class_name RunningState 

func enter(ownr: Knight) -> void:
	if ownr.queued_jump_timer > 0.0:
		ownr.change_state(ownr.jumping_state)
		return
	ownr.animation.play("run")
	ownr.is_bouncing = false
	ownr.cling_blocker = true 

func update(ownr: Knight, _delta: float) -> void:
	ownr.velocity.x = ownr.speed * ownr.movement
	ownr.coyote_timer = ownr.max_coyote_time
	

func handle_input(ownr: Knight) -> void:
	if !ownr.is_on_floor():
		ownr.change_state(ownr.falling_state)
	if !Input.is_action_pressed("left") and !Input.is_action_pressed("right"):
		ownr.change_state(ownr.idle_state)
	

	if ownr.movement != 0.0:
		ownr.direction = ownr.movement
	ownr.animation.flip_h = ownr.direction == -1

	if Input.is_action_just_pressed("jump"):
		ownr.change_state(ownr.jumping_state)


func exit(_ownr) -> void:
	pass
