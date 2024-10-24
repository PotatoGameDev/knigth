extends Node
class_name ZombiIdleState 

func enter(ownr: Zombi) -> void:
	ownr.animation.play("idle")
	ownr.velocity = Vector2.ZERO

func update(ownr: Zombi, delta: float) -> void:
	# TODO: Move to falling state
	if !ownr.is_on_floor():
		ownr.velocity.y += ownr.gravity * delta
		if ownr.velocity.y > ownr.max_fall_speed:
			ownr.velocity.y = ownr.max_fall_speed

	if ownr.detectorLeft.is_colliding():
		ownr.direction = -1
		ownr.movement = -1.0
		ownr.change_state(ownr.running_state)
		return
	elif ownr.detectorRight.is_colliding():
		ownr.direction = 1
		ownr.movement = 1.0
		ownr.change_state(ownr.running_state)
		return
	elif ownr.attackRayLeft.is_colliding():
		ownr.direction = -1
		ownr.change_state(ownr.attacking_state)
		return
	elif ownr.attackRayRight.is_colliding():
		ownr.direction = 1
		ownr.change_state(ownr.attacking_state)
		return

func exit(_ownr: Zombi) -> void:
	pass
