extends MeshInstance3D

@export var grass : MultiMeshInstance3D
@export var loading : LoadingScreen
@export_range(0.0, 10.0) var density : float = 1.0
@export_range(0.0, 1.0) var grass_randomness : float = 0.5
@export var object_per_loading_refresh : int = 50

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_scene()


func load_scene():
	print("Chargement de la scène")
	if loading:
		loading.visible = true
	var map_total_height = get_aabb().size.y
	await generate_grass(-int(get_aabb().size.y/2), map_total_height, get_aabb(), 1.0/density)
	if loading:
		loading.visible = false

func generate_grass(start_height : int, map_height : int, map_aabb : AABB, spacing : float):
	var col = RayCast3D.new()
	col.enabled = true
	col.collide_with_bodies = true
	col.collision_mask = 1
	add_child(col)
	print("Generating grass")
	var object_count = 0
	var max_object_count = int((map_aabb.size.x/spacing) * (map_aabb.size.z/spacing))
	if grass:
		for x in range(0,int(map_aabb.size.x/spacing),spacing):
			for z in range(0,int(map_aabb.size.z/spacing),spacing):
				col.global_position = Vector3(x, start_height + map_height,z)
				col.target_position = Vector3(0, -map_height, 0)
				col.force_raycast_update()
				var grass_position = (col.get_collision_point() if col.is_colliding() else Vector3(x, 0, z)) + Vector3(randf_range(-grass_randomness*spacing, grass_randomness*spacing), 0, randf_range(-grass_randomness*spacing, grass_randomness*spacing))
				var grass_normal = col.get_collision_normal() if col.is_colliding() else Vector3.UP
				var random_rotation = randf_range(0, 2*PI)
				print("Grass: ", grass_position, grass_normal, Vector3.ONE, random_rotation)
				grass.add_grass(grass_position, grass_normal, Vector3.ONE, random_rotation)
				object_count += 1
				if object_count % object_per_loading_refresh == 0:
					if loading:
						loading.current = object_count
						loading.total = max_object_count
					await get_tree().process_frame

		grass._update_multimesh()
		grass.update_all_material()
	else:
		push_error("Grass not found")

	remove_child(col)
	col.queue_free()
	
