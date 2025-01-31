extends KnightState
class_name StompingState

func enter(ownr, _params: Dictionary = {}) -> void:
	ownr.animation.play("stomp")
	ownr.jump_timer = 0.0
	ownr.coyote_timer = 0.0
	ownr.velocity = Vector2.ZERO

func physics_update(ownr: Knight, _delta: float) -> void:
	ownr.move_and_slide()

	if ownr.animation.frame == ownr.animation.sprite_frames.get_frame_count(ownr.animation.animation) - 1:
		ownr.change_state(ownr.jumping_state, {"bouncing": true})
		return


