extends Node
class_name PushBackState

var forced_direction := 0
var pushback_force := 100.0
var incapacitation_time := 1.0

func enter(ownr, params: Dictionary = {}) -> void:
	forced_direction = -ownr.direction
	incapacitation_time = 1.0

	#pushback_force = params["pushback_force"]
	
	var attack_direction: Vector2 = params["direction"]

	if attack_direction.x > 0:
		forced_direction = Global.LEFT
		pushback_force = -pushback_force
	elif attack_direction.x < 0:
		forced_direction = Global.RIGHT
		pushback_force = -pushback_force

	ownr.velocity.x = pushback_force * forced_direction
	ownr.velocity.y = 0.0


func update(ownr: Knight, delta: float) -> void:
	if incapacitation_time > 0.0:
		incapacitation_time -= delta
	else:
		ownr.change_state(ownr.idle_state)
		return

func physics_update(ownr: Knight, delta: float) -> void:
	ownr.move_and_slide()

	if not ownr.is_on_floor():
		ownr.velocity.y += Global.gravity * delta

	ownr.velocity.x = pushback_force * forced_direction

func handle_input(ownr: Knight, event: InputEvent) -> void:
	pass

func exit(_ownr) -> void:
	pass
