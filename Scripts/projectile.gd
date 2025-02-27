extends RayCast3D
@export var speed := 5.0
@export var graviter := Vector3.ZERO
@onready var remote_tranform := RemoteTransform3D.new()
@onready var collision_shape = $Area3D/CollisionShape3D

func _physics_process(delta: float) -> void:
	position += global_basis* Vector3.FORWARD * speed * delta -graviter
	target_position = Vector3.FORWARD*speed*delta -	graviter
	speed -= graviter[1]
	force_raycast_update()
	var collider = get_collider()
	if is_colliding():
		global_position = get_collision_point()
		collision_shape.disabled = true
		set_physics_process(false)
		collider.add_child(remote_tranform)
		remote_tranform.global_transform = global_transform
		remote_tranform.remote_path = remote_tranform.get_path_to(self)
		remote_tranform.tree_exited.connect(cleanup)
func cleanup() -> void:
	queue_free()


func _on_area_3d_area_entered(area: Area3D) -> void:
	pass
