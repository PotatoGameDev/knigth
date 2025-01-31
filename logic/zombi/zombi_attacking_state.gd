extends Node
class_name ZombiAttackingState

var damage_lock = false

func enter(ownr: Zombi) -> void:
	ownr.animation.play("attack")

func update(ownr: Zombi, _delta: float) -> void:
	var player = null
	########var dir_to_player = ownr.global_position - ownr.attackRayLeft.get_collider().global_position
	var dir_to_player = null

	if ownr.attackRayLeft.is_colliding():
		ownr.direction = Global.LEFT
		player = ownr.attackRayLeft.get_collider()
		dir_to_player = -ownr.attackRayLeft.get_collision_normal()
	elif ownr.attackRayRight.is_colliding():
		ownr.direction = Global.RIGHT
		dir_to_player = -ownr.attackRayRight.get_collision_normal()
		player = ownr.attackRayRight.get_collider()
	else:
		ownr.change_state(ownr.running_state)
		return

	if ownr.animation.frame_progress >= 0.5:
		if not damage_lock:
			#player.take_damage(ownr.strength, ownr.global_position - player.global_position)
			player.take_damage(ownr.strength, dir_to_player)
			# TODO: No need, since we have a state level damage function, that can not accept the damage in pushback state
			# But better think about it
			damage_lock = true
	else:
		damage_lock = false
	
	ownr.animation.flip_h = ownr.direction == Global.LEFT 
	

func exit(_ownr: Zombi) -> void:
	pass
