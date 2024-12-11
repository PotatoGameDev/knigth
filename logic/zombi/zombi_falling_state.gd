extends Node
class_name ZombiFallingState

func enter(ownr: Zombi) -> void:
	ownr.animation.play("idle") # TODO: Change to falling

func update(ownr: Zombi, delta: float) -> void:
	if ownr.is_on_floor():
		ownr.change_state(ownr.idle_state)
		return

	ownr.velocity.y += Global.gravity * delta
	if ownr.velocity.y > ownr.max_fall_speed:
		ownr.velocity.y = ownr.max_fall_speed

	ownr.animation.flip_h = ownr.direction == -1
	

func exit(_ownr: Zombi) -> void:
	pass
