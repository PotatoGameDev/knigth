extends Node
class_name ZombiDeadState 

func enter(ownr: Zombi) -> void:
	ownr.animation.play("death")
	ownr.velocity = Vector2.ZERO

func update(ownr: Zombi, delta: float) -> void:
	pass

func exit(_ownr: Zombi) -> void:
	pass
