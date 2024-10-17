# The player's idle state.
extends Node
class_name FallingState 

var movement := 0.0

func enter(ownr) -> void:
	ownr.animation.play("fall")
	ownr.animation.frame = 1

func update(ownr: Knight, delta: float) -> void:
	if ownr.is_on_floor():
		ownr.change_state(ownr.idle_state)
	else:
		ownr.velocity.y += ownr.gravity * delta
		ownr.velocity.x = movement * ownr.speed

func handle_input(ownr: Knight) -> void:
	if Input.is_action_pressed("left"):
		ownr.direction = -1
	elif Input.is_action_pressed("right"):
		ownr.direction = 1

	if Input.is_action_just_pressed("jump") and ownr.coyote_timer > 0.0:
		ownr.change_state(ownr.jumping_state)

	movement = Input.get_action_strength("right") - Input.get_action_strength("left")
	ownr.animation.flip_h = ownr.direction == -1
	
func exit(ownr) -> void:
	ownr.velocity.y = 0
