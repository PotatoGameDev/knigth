extends Node
class_name ClingingState

@export var gravity_coefficient := 0.2

func enter(ownr) -> void:
	ownr.animation.play("cling")
	ownr.velocity = Vector2.ZERO

	ownr.is_bouncing = false

func update(ownr, delta: float) -> void:
	if not ownr.is_on_floor():
		ownr.velocity.y += gravity_coefficient * ownr.gravity * delta
		if not ownr.wallClingSensorRight.is_colliding() && not ownr.wallClingSensorLeft.is_colliding():
			ownr.change_state(ownr.falling_state)
			return
	else:
		ownr.change_state(ownr.idle_state)
		return
	

func handle_input(ownr: Knight) -> void:
	if Input.is_action_just_pressed("jump"):
		ownr.change_state(ownr.jumping_state)
		return

func exit(_ownr) -> void:
	pass
