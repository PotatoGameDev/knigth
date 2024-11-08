extends Node
class_name StompingState

func enter(ownr) -> void:
	ownr.animation.play("stomp")
	ownr.velocity.y = -ownr.jump_force
	ownr.jump_timer = 0.0
	ownr.coyote_timer = 0.0
	ownr.velocity.y = 0.0	

func update(ownr: Knight, _delta: float) -> void:
	if ownr.animation.frame == ownr.animation.sprite_frames.get_frame_count(ownr.animation.animation) - 1:
		ownr.change_state(ownr.bouncing_state)
		return

func handle_input(ownr: Knight) -> void:
	if ownr.movement != 0:
		ownr.direction = ownr.movement

	ownr.animation.flip_h = ownr.direction == -1

func exit(_ownr) -> void:
	pass


