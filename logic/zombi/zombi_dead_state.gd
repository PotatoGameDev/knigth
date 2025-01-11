extends Node
class_name ZombiDeadState 

func enter(ownr: Zombi) -> void:
	ownr.animation.play("die")
	ownr.velocity = Vector2.ZERO
	ownr.collision_shape.disabled = true

func update(_ownr: Zombi, _delta: float) -> void:
	pass

func exit(_ownr: Zombi) -> void:
	pass
