extends Node
class_name ClingingState

@export var gravity_coefficient := 0.2

var snapped_already := false
var snapping_speed := 50.0

func enter(ownr) -> void:
	ownr.animation.play("cling")
	ownr.velocity = Vector2.ZERO

	if ownr.can_cling_right():
		ownr.direction = 1
	elif ownr.can_cling_left():
		ownr.direction = -1
	ownr.animation.flip_h = ownr.direction == -1

	ownr.is_bouncing = false
	snapped_already = false

func update(ownr: Knight, delta: float) -> void:
	pass

func physics_update(ownr: Knight, delta: float) -> void:
	if not ownr.is_on_floor():
		ownr.velocity.y += gravity_coefficient * Global.gravity * delta

	ownr.move_and_slide()

	if not ownr.is_on_floor():
		if not ownr.can_cling_right() and not ownr.can_cling_left():
			ownr.change_state(ownr.falling_state)
			return
		ownr.jump_stamina_left -= delta * ownr.jump_stamina_depletion_multiplier
		ownr.jump_stamina_left = max(ownr.jump_stamina_left, 0.0)

		if ownr.jump_stamina_left <= 0.0:
			ownr.change_state(ownr.falling_state)
			return
	

func handle_input(ownr: Knight, event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		if (Input.is_action_pressed("left") and ownr.direction == ownr.LEFT) or (Input.is_action_pressed("right") and ownr.direction == ownr.RIGHT):
			ownr.cling_blocker = true
			ownr.change_state(ownr.jumping_state)
			return
		else:
			ownr.change_state(ownr.pushoff_state)
			return
	if event.is_action_pressed("smash"):
		if ownr.is_on_floor():
			ownr.change_state(ownr.idle_state)
			return
		else:
			ownr.change_state(ownr.smashing_state)
			return
	if (event.is_action_pressed("left") and ownr.is_right()) or (event.is_action_pressed("right") and ownr.is_left()):
		ownr.change_state(ownr.falling_state)
		return

	if event.is_action_pressed("down"):
		ownr.change_state(ownr.falling_state)
		return


func exit(ownr) -> void:
	ownr.cling_blocker = true
	ownr.coyote_timer = ownr.max_coyote_time
