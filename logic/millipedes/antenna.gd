extends Node2D

@export var ritter : Knight

@onready var target: Node2D = $Target

func _process(delta):
	target.global_position = ritter.global_position
