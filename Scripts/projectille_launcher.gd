extends Node3D
@export var PROJECTILE : PackedScene
@onready var timer : Timer = $Timer

func _on_character_body_3d_projectile_fired() -> void:
	var attack = PROJECTILE.instantiate()
	add_child(attack)
	attack.global_transform = global_transform
