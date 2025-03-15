extends MeshInstance3D

@export var balle : RigidBody3D
@export var object_per_loading_refresh : int = 50
@export var loading : LoadingScreen
@export_category("Grass")
@export var grass : MultiMeshInstance3D
@export_range(0.0, 1.0) var density : float = 1.0
@export_range(0.0, 3.0) var grass_randomness : float = 0.5
@export_category("Generator")
@export var size : int = 256
@export var max_height : int = 20
@export var noise_zoom : float = 1.0
@export var noise : FastNoiseLite = FastNoiseLite.new() :
	set(value):
		noise = value
		generate_terrain()

var surface_tool = SurfaceTool.new()

func _ready():
	generate_terrain()
	load_scene()

func _process(_delta):
	if Input.is_action_just_pressed("left_click"):
		print("Reloading Terrain")
		generate_terrain()
	if Input.is_action_just_pressed("tire"):
		print("Teleporting Ball")
		if balle:
			balle.global_position = get_viewport().get_camera_3d().global_position
			balle.set_deferred("linear_velocity", Vector2.ZERO)
			balle.set_deferred("angular_velocity", 0)
			balle.set_deferred("constant_force", Vector2.ZERO)
			balle.rotation_degrees = Vector3.ZERO
		else:
			push_error("No ball found")

func generate_terrain():
	# Clean previous collision by erasing child

	for child in get_children():
		if child is StaticBody3D:
			remove_child(child)
			child.queue_free()

	var heightmap = []
	for x in range(size):
		heightmap.append([])
		for y in range(size):
			var height = noise.get_noise_2d(x / noise_zoom, y / noise_zoom) * max_height
			heightmap[x].append(height)

	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	for x in range(size - 1):
		for y in range(size - 1):
			var p1 = Vector3(x, heightmap[x][y], y)
			var p2 = Vector3(x + 1, heightmap[x + 1][y], y)
			var p3 = Vector3(x, heightmap[x][y + 1], y + 1)
			var p4 = Vector3(x + 1, heightmap[x + 1][y + 1], y + 1)

			surface_tool.add_vertex(p1)
			surface_tool.add_vertex(p2)
			surface_tool.add_vertex(p3)

			surface_tool.add_vertex(p2)
			surface_tool.add_vertex(p4)
			surface_tool.add_vertex(p3)

	self.mesh = surface_tool.commit()
	create_trimesh_collision()
	# Apply water texture
	var water_material = load("res://world_water.tres")

	self.material_override = water_material
	# Adapt UV for water and for the size of the terrain
	self.material_override.set("uv1_scale", Vector2(1/size, 1/size))



func load_scene():
	print("Chargement de la scène")
	if loading:
		loading.visible = true
	var map_total_height = get_aabb().size.y
	generate_grass(-int(get_aabb().size.y/2), map_total_height, get_aabb(), 1.0/density)
	await get_tree().create_timer(1.0).timeout
	if loading:
		loading.visible = false

func generate_grass(start_height : int, map_height : int, map_aabb : AABB, spacing : float):
	var col = RayCast3D.new()
	col.enabled = true
	col.collide_with_bodies = true
	col.collision_mask = 1
	add_child(col)
	#print("Generating grass")
	var object_count = 0
	var next_update = object_count + object_per_loading_refresh
	var max_object_count = int((map_aabb.size.x/spacing) * (map_aabb.size.z/spacing))
	if grass:
		for x in range(0,map_aabb.size.x,spacing):
			for z in range(0,map_aabb.size.z,spacing):
				var variation = Vector3(randf_range(-grass_randomness*spacing, grass_randomness*spacing), 0, randf_range(-grass_randomness*spacing, grass_randomness*spacing))
				col.global_position = Vector3(x, start_height + map_height,z) + variation
				col.target_position = Vector3(0, -map_height, 0)  + variation
				col.force_raycast_update()
				var grass_position = (col.get_collision_point() if col.is_colliding() else Vector3(x, 0, z))
				var grass_normal = col.get_collision_normal() if col.is_colliding() else Vector3.UP
				var random_rotation = randf_range(0, 2*PI)
				#print("Grass: ", grass_position, grass_normal, Vector3.ONE, random_rotation)
				grass.add_grass(grass_position, grass_normal, Vector3.ONE, random_rotation)
				object_count += 1
				if object_count >= next_update:
					if loading:
						loading.current = object_count
						loading.total = max_object_count
					next_update += object_per_loading_refresh
					await get_tree().process_frame
		if loading:
			loading.current = object_count
			loading.total = max_object_count
		grass._update_multimesh()
		grass.update_all_material()
	else:
		push_error("Grass not found")
	await get_tree().process_frame
	remove_child(col)
	col.queue_free()


func generate_trees(start_height : int, map_height : int, map_aabb : AABB, spacing : float):
	var col = RayCast3D.new()
	col.enabled = true
	col.collide_with_bodies = true
	col.collision_mask = 1
	add_child(col)
	#print("Generating grass")
	var object_count = 0
	var next_update = object_count + object_per_loading_refresh
	var max_object_count = int((map_aabb.size.x/spacing) * (map_aabb.size.z/spacing))
	if grass:
		for x in range(0,map_aabb.size.x,spacing):
			for z in range(0,map_aabb.size.z,spacing):
				var variation = Vector3(randf_range(-grass_randomness*spacing, grass_randomness*spacing), 0, randf_range(-grass_randomness*spacing, grass_randomness*spacing))
				col.global_position = Vector3(x, start_height + map_height,z) + variation
				col.target_position = Vector3(0, -map_height, 0)  + variation
				col.force_raycast_update()
				var grass_position = (col.get_collision_point() if col.is_colliding() else Vector3(x, 0, z))
				var grass_normal = col.get_collision_normal() if col.is_colliding() else Vector3.UP
				var random_rotation = randf_range(0, 2*PI)
				#print("Grass: ", grass_position, grass_normal, Vector3.ONE, random_rotation)
				grass.add_grass(grass_position, grass_normal, Vector3.ONE, random_rotation)
				object_count += 1
				if object_count >= next_update:
					if loading:
						loading.current = object_count
						loading.total = max_object_count
					next_update += object_per_loading_refresh
					await get_tree().process_frame
		if loading:
			loading.current = object_count
			loading.total = max_object_count
		grass._update_multimesh()
		grass.update_all_material()
	else:
		push_error("Grass not found")
	await get_tree().process_frame
	remove_child(col)
	col.queue_free()


func generate_grass(start_height : int, map_height : int, map_aabb : AABB, spacing : float):
	var col = RayCast3D.new()
	col.enabled = true
	col.collide_with_bodies = true
	col.collision_mask = 1
	add_child(col)
	#print("Generating grass")
	var object_count = 0
	var next_update = object_count + object_per_loading_refresh
	var max_object_count = int((map_aabb.size.x/spacing) * (map_aabb.size.z/spacing))
	if grass:
		for x in range(0,map_aabb.size.x,spacing):
			for z in range(0,map_aabb.size.z,spacing):
				var variation = Vector3(randf_range(-grass_randomness*spacing, grass_randomness*spacing), 0, randf_range(-grass_randomness*spacing, grass_randomness*spacing))
				col.global_position = Vector3(x, start_height + map_height,z) + variation
				col.target_position = Vector3(0, -map_height, 0)  + variation
				col.force_raycast_update()
				var grass_position = (col.get_collision_point() if col.is_colliding() else Vector3(x, 0, z))
				var grass_normal = col.get_collision_normal() if col.is_colliding() else Vector3.UP
				var random_rotation = randf_range(0, 2*PI)
				#print("Grass: ", grass_position, grass_normal, Vector3.ONE, random_rotation)
				grass.add_grass(grass_position, grass_normal, Vector3.ONE, random_rotation)
				object_count += 1
				if object_count >= next_update:
					if loading:
						loading.current = object_count
						loading.total = max_object_count
					next_update += object_per_loading_refresh
					await get_tree().process_frame
		if loading:
			loading.current = object_count
			loading.total = max_object_count
		grass._update_multimesh()
		grass.update_all_material()
	else:
		push_error("Grass not found")
	await get_tree().process_frame
	remove_child(col)
	col.queue_free()
