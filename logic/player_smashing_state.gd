# The player's idle state.
extends Node
class_name SmashingState

@export var gravity_coefficient := 2.0
@export var controls_coefficient := 0.5

func enter(ownr) -> void:
	ownr.animation.play("smash")
	ownr.velocity.y = ownr.max_fall_speed * 0.5
	ownr.coyote_timer = 0.0

func update(ownr: Knight, delta: float) -> void:
	if ownr.is_on_floor():
		ownr.queued_jump_timer = 0.0
		ownr.change_state(ownr.idle_state)
		return
	else:
		ownr.velocity.y += ownr.gravity * gravity_coefficient * delta
		ownr.velocity.x = ownr.movement * controls_coefficient * ownr.speed

func handle_input(ownr: Knight) -> void:
	if ownr.movement != 0:
		ownr.direction = ownr.movement

	ownr.animation.flip_h = ownr.direction == -1

	if Input.is_action_just_pressed("jump") and ownr.coyote_timer > 0.0:
		ownr.change_state(ownr.jumping_state)
		return
	
func exit(ownr) -> void:
	ownr.velocity.y = 0
