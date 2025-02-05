extends Node3D
const PROJECTILE= preload("res://scéne/entiter/projectile.tscn")
@onready var timer : Timer = $Timer

#func _physics_process(delta: float) -> void:
	#if Input.is_action_just_pressed("e"):
		#var attack = PROJECTILE.instantiate()
		#add_child(attack)
		#attack.global_transform = global_transform


func _on_character_body_3d_projectile_fired() -> void:
	var attack = PROJECTILE.instantiate()
	add_child(attack)
	attack.global_transform = global_transform
