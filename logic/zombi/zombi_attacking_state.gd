extends Node
class_name ZombiAttackingState

func enter(ownr: Zombi) -> void:
	ownr.animation.play("attack")

func update(ownr: Zombi, delta: float) -> void:
	if ownr.attackRayLeft.is_colliding():
		ownr.direction = -1
	elif ownr.attackRayRight.is_colliding():
		ownr.direction = 1
	else:
		ownr.change_state(ownr.running_state)
		return

	ownr.animation.flip_h = ownr.direction == -1
	

func exit(ownr: Zombi) -> void:
	pass
