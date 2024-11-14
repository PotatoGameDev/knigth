extends Node
class_name StompingState

func enter(ownr) -> void:
	ownr.animation.play("stomp")
	ownr.jump_timer = 0.0
	ownr.coyote_timer = 0.0
	ownr.velocity = Vector2.ZERO

func update(ownr: Knight, _delta: float) -> void:
	if ownr.animation.frame == ownr.animation.sprite_frames.get_frame_count(ownr.animation.animation) - 1:
		ownr.change_state(ownr.bouncing_state)
		return

func handle_input(_ownr: Knight) -> void:
	pass

func exit(_ownr) -> void:
	pass


