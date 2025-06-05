extends AnimatableBody2D

func get_friction() -> float:
	return get_parent().get_friction()
