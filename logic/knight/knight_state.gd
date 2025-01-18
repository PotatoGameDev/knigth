extends Node
class_name KnightState 

var options: StateOptions = StateOptions.new()

func enter(ownr: Knight, params: Dictionary = {}) -> void:
	pass

func update(ownr: Knight, delta: float) -> void:
	pass

func handle_input(ownr: Knight, event: InputEvent) -> void:
	pass

func exit(_ownr) -> void:
	pass

func take_damage(ownr: Knight, damage: int, direction: Vector2) -> void:
	pass

func integrate_forces(ownr: Knight, state: PhysicsDirectBodyState2D) -> void:
	pass

class StateOptions:
	var calculate_direction := true
	var calculate_movement := true
	var calculate_queued_jump_timer := true
