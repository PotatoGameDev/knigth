extends KnightState
class_name PushBackState

var forced_direction := 0
var pushback_force := 100.0
var incapacitation_time : float

func enter(ownr, params: Dictionary = {}) -> void:
	incapacitation_time = 0.5

	#pushback_force = params["pushback_force"]
	
	var attack_direction: Vector2 = params["direction"]

	if attack_direction.x > 0:
		forced_direction = Global.RIGHT
	elif attack_direction.x < 0:
		forced_direction = Global.LEFT

	if ownr.direction == forced_direction:
		ownr.animation.play("push_forward")
	else:
		ownr.animation.play("push_back")
	
	ownr.velocity.x = pushback_force * forced_direction
	ownr.velocity.y = 0.0


func update(ownr: Knight, delta: float) -> void:
	if incapacitation_time > 0.0:
		incapacitation_time -= delta
	else:
		ownr.change_state(ownr.idle_state)
		return

func integrate_forces(ownr: Knight, state: PhysicsDirectBodyState2D) -> void:
	ownr.velocity.x = pushback_force * forced_direction
