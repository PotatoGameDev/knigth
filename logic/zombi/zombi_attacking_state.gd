extends Node
class_name ZombiAttackingState

var damage_lock = false

func enter(ownr: Zombi) -> void:
	ownr.animation.play("attack")

func update(ownr: Zombi, delta: float) -> void:
	var player = null
	if ownr.attackRayLeft.is_colliding():
		ownr.direction = Global.LEFT
		player = ownr.attackRayLeft.get_collider()
	elif ownr.attackRayRight.is_colliding():
		ownr.direction = Global.RIGHT
		player = ownr.attackRayRight.get_collider()
	else:
		ownr.change_state(ownr.running_state)
		return

	if ownr.animation.frame_progress >= 0.5:
		player.take_damage(ownr.strength, ownr.global_position - player.global_position)
		damage_lock = true
	else:
		damage_lock = false
	
	ownr.animation.flip_h = ownr.direction == Global.LEFT 
	

func exit(ownr: Zombi) -> void:
	pass
