extends Node
class_name ClingingState

@export var gravity_coefficient := 0.2

func enter(ownr) -> void:
	ownr.animation.play("cling")
	ownr.velocity = Vector2.ZERO

	if ownr.wallClingSensorRight.is_colliding():
		ownr.direction = 1
	elif ownr.wallClingSensorLeft.is_colliding():
		ownr.direction = -1
	ownr.animation.flip_h = ownr.direction == -1

	ownr.is_bouncing = false

func update(ownr, delta: float) -> void:
	if not ownr.is_on_floor():
		ownr.velocity.y += gravity_coefficient * ownr.gravity * delta
		if not ownr.wallClingSensorRight.is_colliding() && not ownr.wallClingSensorLeft.is_colliding():
			ownr.change_state(ownr.falling_state)
			return
		ownr.jump_stamina_left -= delta * ownr.jump_stamina_depletion_multiplier
		ownr.jump_stamina_left = max(ownr.jump_stamina_left, 0.0)

		if ownr.jump_stamina_left <= 0.0:
			ownr.change_state(ownr.falling_state)
			return
	else:
		ownr.change_state(ownr.idle_state)
		return
	

func handle_input(ownr: Knight) -> void:
	if Input.is_action_just_pressed("jump"):
		ownr.change_state(ownr.pushoff_state)
		return

	if Input.is_action_just_pressed("smash"):
		ownr.change_state(ownr.smashing_state)
		return

	if Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right"):
		ownr.change_state(ownr.falling_state)
		return


func exit(ownr) -> void:
	ownr.cling_blocker = true
	ownr.coyote_timer = ownr.max_coyote_time
