# head.gd
extends AnimatedSprite2D
class_name MillipedesHeadEnhancedEdition

@export var path_follow : PathFollow2D = null
@export var friction := 0.3

func get_friction() -> float:
	return friction
