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
		ownr.velocity.y += ownr.GRAVITY * delta

func handle_input(_ownr: Knight) -> void:
	pass
	
func exit(ownr) -> void:
	ownr.velocity.y = 0


