extends Node
class_name KnightState 

func enter(ownr: Knight, params: Dictionary = {}) -> void:
	pass

func update(ownr: Knight, delta: float) -> void:
	pass

func physics_update(ownr: Knight, delta: float) -> void:
	pass

func handle_input(ownr: Knight, event: InputEvent) -> void:
	pass

func exit(_ownr) -> void:
	pass

func take_damage(ownr: Knight, damage: int, direction: Vector2) -> void:
	pass
