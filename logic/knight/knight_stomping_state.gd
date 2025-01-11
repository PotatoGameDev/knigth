extends KnightState
class_name StompingState

func enter(ownr, params: Dictionary = {}) -> void:
	ownr.animation.play("stomp")
	ownr.jump_timer = 0.0
	ownr.coyote_timer = 0.0
	ownr.velocity = Vector2.ZERO

func update(ownr: Knight, delta: float) -> void:
	pass

func physics_update(ownr: Knight, delta: float) -> void:
	ownr.move_and_slide()
	print("FRODO LIVES")

	if ownr.animation.frame == ownr.animation.sprite_frames.get_frame_count(ownr.animation.animation) - 1:
		ownr.change_state(ownr.jumping_state, {"bouncing": true})
		return

func handle_input(_ownr: Knight, _event: InputEvent) -> void:
	pass

func exit(_ownr) -> void:
	pass


