# The player's idle state.
extends Node
class_name FallingState 

func enter(ownr) -> void:
	ownr.animation.play("fall")
	ownr.animation.frame = 1

func update(ownr: Knight, delta: float) -> void:
	if ownr.is_on_floor():
		ownr.change_state(ownr.idle_state)
	else:
		ownr.velocity.y += ownr.gravity * delta
		ownr.velocity.x = ownr.movement * ownr.speed

	ownr.coyote_timer -= delta

func handle_input(ownr: Knight) -> void:
	if ownr.movement != 0:
		ownr.direction = ownr.movement

	ownr.animation.flip_h = ownr.direction == -1

	if Input.is_action_just_pressed("jump") and ownr.coyote_timer > 0.0:
		ownr.change_state(ownr.jumping_state)
	
func exit(ownr) -> void:
	ownr.velocity.y = 0
