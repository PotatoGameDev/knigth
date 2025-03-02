extends Node
class_name KnightState 

var options: StateOptions = StateOptions.new()

func enter(_ownr: Knight, _params: Dictionary = {}) -> void:
	pass

func update(_ownr: Knight, _delta: float) -> void:
	pass

func physics_update(_ownr: Knight, _delta: float) -> void:
	pass

func handle_input(_ownr: Knight, _event: InputEvent) -> void:
	pass

func exit(_ownr) -> void:
	pass

func take_damage(_ownr: Knight, _damage: int, _direction: Vector2) -> void:
	pass

class StateOptions:
	var calculate_direction := true
	var calculate_movement := true
	var calculate_queued_jump_timer := true
	var add_gravity := true
