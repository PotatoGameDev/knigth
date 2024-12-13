extends Node
class_name ZombiRunningState 

# This means the zombi will move a bit and then stop for a moment
# TODO: This is not related to stepping on a step, should be renamed.
var stepping := false

func enter(_ownr: Zombi) -> void:
	stepping = true

func update(ownr: Zombi, delta: float) -> void:
	if stepping:
		ownr.velocity.x = ownr.speed * ownr.movement
		ownr.animation.play("run")
	else:
		ownr.velocity.x = 0.0
		ownr.animation.play("idle")

	# TODO: Move to falling state
	if !ownr.is_on_floor():
		ownr.velocity.y += Global.gravity * delta
		if ownr.velocity.y > ownr.max_fall_speed:
			ownr.velocity.y = ownr.max_fall_speed
	
	if !ownr.detectorLeft.is_colliding() and !ownr.detectorRight.is_colliding():
		ownr.change_state(ownr.idle_state)
		return
	elif ownr.attackRayLeft.is_colliding():
		ownr.direction = Global.LEFT
		ownr.movement = -1.0
		ownr.change_state(ownr.attacking_state)
		return
	elif ownr.attackRayRight.is_colliding():
		ownr.direction = Global.RIGHT
		ownr.movement = 1.0
		ownr.change_state(ownr.attacking_state)
		return
	
	ownr.animation.flip_h = ownr.direction == Global.LEFT
	
func exit(_ownr) -> void:
	pass

func _on_step_timer_timeout() -> void:
	stepping = !stepping
