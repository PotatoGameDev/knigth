extends KnightState
class_name SmashingState

@export var gravity_coefficient := 2.0
@export var min_controls_coefficient := 0.0
@export var max_controls_coefficient := 2.0 
@export var controls_coefficient_grow_rate := 20.0

var controls_coefficient := 0.0
const BOUNCE_POWER := 1.5

func enter(ownr, params: Dictionary = {}) -> void:
	ownr.animation.play("smash")
	ownr.velocity.y = 0.0
	ownr.velocity.x = 0.0
	controls_coefficient = min_controls_coefficient

func update(_ownr: Knight, _delta: float) -> void:
	pass

func integrate_forces(ownr: Knight, state: PhysicsDirectBodyState2D) -> void:
	var delta = state.get_step()

	if ownr.is_on_floor():
		var enemy = ownr.get_floor_collision_object()
		if enemy is Zombi:
			enemy.take_damage(ownr.strength * ownr.old_velocity.length() * ownr.smash_speed_damage_factor)
			ownr.bounce_power = BOUNCE_POWER
			ownr.change_state(ownr.stomping_state)
			return

	if Input.is_action_pressed("smash"):
		controls_coefficient = min(
			controls_coefficient + delta * controls_coefficient_grow_rate,
			max_controls_coefficient
			)
	else:
		controls_coefficient = min_controls_coefficient

	if ownr.is_on_floor():
 		# zero out queued jump timer to prevent double jumps when landing after smashing
		ownr.queued_jump_timer = 0.0
		ownr.change_state(ownr.idle_state)
		return
	else:
		ownr.velocity += state.get_total_gravity() * gravity_coefficient * delta
		ownr.velocity.x = ownr.movement * controls_coefficient * ownr.speed

func handle_input(ownr: Knight, event: InputEvent) -> void:
	if event.is_action_pressed("jump") and ownr.coyote_timer > 0.0:
		ownr.change_state(ownr.jumping_state)
		return
	
func exit(ownr) -> void:
	ownr.velocity.y = 0
	
