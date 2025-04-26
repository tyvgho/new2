class_name WorldGenerator extends MeshInstance3D

@export var debugging : bool = false
@export var reuse_assets : bool = false
@export var mesh_file : String = "res://generated_mesh.tres"
@export var balle : RigidBody3D
@export var use_percentage_loading : bool = true
@export var object_per_loading_refresh : int = 50
@export_range(0.01, 1.0) var next_percentage_to_refresh : float = 0.1
@export var loading : LoadingScreen
@export var player : Player

@export_category("Grass")
@export var do_generate_grass : bool = false
@export var grass : Grass
@export var max_height_percentage_grass : float = 0.7
@export var min_height_percentage_grass : float = 0.3
@export_range(0.0, 1.0) var density : float = 1.0
@export_range(0.0, 3.0) var grass_randomness : float = 0.5

@export_category("Trees")
@export var trees : Array[PackedScene]
@export var variation : float = 0.5
@export var tree_height_spawnrate : Curve
@export var tree_randomness : float = 0.5
@export_category("Generator")
@export var generator_size : int = 256
@export var max_height : int = 20
@export var inversed : bool = false
@export var water : Node3D
@export var water_percentage : float = 0.2 : set = _set_water_height
@export var noise_zoom : float = 1.0
@export var terrain_gradient : Gradient
@export var noise : FastNoiseLite = FastNoiseLite.new() :
	set(value):
		noise = value
		#generate_terrain(get_tree())

var surface_tool = SurfaceTool.new()

func _set_water_height(value : float):
	water_percentage = value
	if water:
		water.global_position.y = minimum_height + abs((maximum_height - minimum_height)*water_percentage)
	else:
		push_error("Couldn't find water")

func _ready():
	pass

func transpose(value : float, min : float, max : float, new_min : float, new_max : float) -> float:
	return (value - min) / (max - min) * (new_max - new_min) + new_min

func _process(_delta):
	if not Engine.is_editor_hint():
		if Input.is_action_just_pressed("left_click"):
			pass
			#print("Reloading Terrain")
			#generate_terrain(get_tree())
		if grass and player and grass is Grass:
			SimpleGrass.set_player_position(player.global_position)

var vertex_map = {}
var vertex_count = 0

func add_vertex_with_uv(pos: Vector3, uv: Vector2) -> int:
	if not vertex_map.has(pos):
		surface_tool.set_uv(uv)

		if debugging:
			surface_tool.set_color(terrain_gradient.sample(transpose(pos.y, minimum_height, maximum_height, 0.0, 1.0)))

		surface_tool.add_vertex(pos)
		vertex_map[pos] = vertex_count
		vertex_count += 1
	return vertex_map[pos]

var surface_uv_image : Image
var maximum_height = noise.get_noise_2d(0, 0)
var minimum_height = maximum_height

func reuse_terrain(tree : SceneTree):
	await tree.process_frame

	for child in get_children():
		if child is StaticBody3D:
			remove_child(child)
			child.queue_free()
	
	ResourceLoader.load_threaded_request("res://terrain.png")
	ResourceLoader.load_threaded_request(mesh_file)
	
	var last_update = 0
	while true:
		if ResourceLoader.load_threaded_get_status("res://terrain.png") == ResourceLoader.THREAD_LOAD_LOADED:
			break
		
		var status = []
		ResourceLoader.load_threaded_get_status("res://terrain.png", status)
		var update = loading.progressive_update(tree, int(status[0]*100), 100, 1, last_update)
		if update != last_update:
			last_update = update
			await tree.process_frame
	var terrain_image = ResourceLoader.load_threaded_get("res://terrain.png")
	ResourceLoader.load_threaded_request(mesh_file)
	while true:
		if ResourceLoader.load_threaded_get_status(mesh_file) == ResourceLoader.THREAD_LOAD_LOADED:
			break
		
		var status = []
		ResourceLoader.load_threaded_get_status(mesh_file, status)
		var update = loading.progressive_update(tree, int(status[0]*100), 100, 1, last_update)
		if update != last_update:
			last_update = update
			await tree.process_frame
	var the_mesh = ResourceLoader.load_threaded_get(mesh_file)
	
	self.mesh = the_mesh
	
	self.material_override.albedo_texture = terrain_image

func generate_terrain(tree : SceneTree):
	var object_count = 0
	var last_update = 0
	#var next_update = object_count + object_per_loading_refresh
	var max_object_count = int(generator_size * generator_size * 2) 
	var current_loading_percentage = next_percentage_to_refresh

	noise.seed = randi()

	# Clean previous collision by erasing child
	for child in get_children():
		if child is StaticBody3D:
			remove_child(child)
			child.queue_free()
	
	# Create a texture that will be modified to match the terrain height with the gradient
	surface_uv_image = Image.create(512, 512, true, Image.FORMAT_RGB8)
	surface_uv_image.fill(Color(0, 0, 0, 1.0))

	# Generate the heightmap
	var heightmap = []
	var maximum_height = noise.get_noise_2d(0, 0)
	var minimum_height = maximum_height

	for x in range(generator_size):
		heightmap.append([])
		for y in range(generator_size):
			var height = (-1 if inversed else 1) * noise.get_noise_2d(float(x) / generator_size * 512.0, float(y) / generator_size * 512.0) * max_height
			minimum_height = min(minimum_height, height)
			maximum_height = max(maximum_height, height)
			heightmap[x].append(height)

			# Update the loading screen
			object_count += 1
			var updated = loading.progressive_update(tree, object_count, max_object_count, int(current_loading_percentage * max_object_count) if use_percentage_loading else object_per_loading_refresh, last_update)
			if updated != last_update:
				last_update = updated
				await tree.process_frame
	
	var heightmap_noise_texture : NoiseTexture2D = NoiseTexture2D.new()
	heightmap_noise_texture.noise = noise
	heightmap_noise_texture.color_ramp = terrain_gradient
	await heightmap_noise_texture.changed
	heightmap_noise_texture.get_image().generate_mipmaps()
	surface_uv_image = heightmap_noise_texture.get_image()

	# Generate the mesh
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.index()
	for x in range(generator_size - 1):
		for y in range(generator_size - 1):
			var p1 = Vector3(x, heightmap[x][y], y)
			var p1v = Vector2(x / float(generator_size), y / float(generator_size))

			var p2 = Vector3(x + 1, heightmap[x + 1][y], y)
			var p2v = Vector2((x + 1) / float(generator_size), y / float(generator_size))

			var p3 = Vector3(x, heightmap[x][y + 1], y + 1)
			var p3v = Vector2(x / float(generator_size), (y + 1) / float(generator_size))

			var p4 = Vector3(x + 1, heightmap[x + 1][y + 1], y + 1)
			var p4v = Vector2((x + 1) / float(generator_size), (y + 1) / float(generator_size))

			var i1 = add_vertex_with_uv(p1, p1v)
			var i2 = add_vertex_with_uv(p2, p2v)
			var i3 = add_vertex_with_uv(p3, p3v)
			surface_tool.add_index(i1)
			surface_tool.add_index(i2)
			surface_tool.add_index(i3)

			var i4 = add_vertex_with_uv(p4, p4v)
			surface_tool.add_index(i3)
			surface_tool.add_index(i2)
			surface_tool.add_index(i4)

			object_count += 1
			var updated = loading.progressive_update(tree, object_count, max_object_count, int(current_loading_percentage * max_object_count) if use_percentage_loading else object_per_loading_refresh, last_update)
			if updated > last_update:
				last_update = updated
				await tree.process_frame

	loading.loading_text = "Finalisation du Terrain... "
	await tree.process_frame
	surface_tool.generate_normals()
	surface_tool.generate_tangents()
	#surface_tool.generate_lod(1024)
	#surface_tool.generate_tangents()
	self.mesh = surface_tool.commit()
	create_trimesh_collision()
	
	self.material_override = StandardMaterial3D.new()
	var image_text : ImageTexture = ImageTexture.create_from_image(surface_uv_image)
	self.material_override.albedo_texture = image_text #preload("res://icon.svg")
	surface_uv_image.save_png("res://world_image.png")

	water_percentage = water_percentage + 0.01

	global_position.x = get_aabb().position.x - get_aabb().size.x / 2.0
	global_position.z = get_aabb().position.z - get_aabb().size.z / 2.0

	self.force_update_transform()

	ResourceSaver.save(self.mesh, mesh_file)
	surface_uv_image.save_png("res://terrain.png")

	# Update the loading bar that shows the progress of the terrain generation
	var updated = loading.progressive_update(tree, object_count, max_object_count, int(current_loading_percentage * max_object_count) if use_percentage_loading else object_per_loading_refresh, last_update)
	await tree.process_frame

func load_scene(tree : SceneTree):
	seed(randi())
	print("Chargement de la scène")
	if loading:
		loading.visible = true
		loading.loading_text = "Génération du Terrain... "
	if reuse_assets and FileAccess.file_exists(mesh_file):
		await reuse_terrain(tree)
	else:
		await generate_terrain(tree)
	var map_total_height = get_aabb().size.y
	if loading: loading.loading_text = "Génération de l'herbe... "
	if do_generate_grass:
		await generate_grass(tree,-int(get_aabb().size.y/2), map_total_height, get_aabb(), 1.0/density)
	await get_tree().create_timer(1.0).timeout
	if loading:
		loading.visible = false

func generate_grass(tree : SceneTree, start_height : int, map_height : int, map_aabb : AABB, spacing : float):
	var col = RayCast3D.new()
	col.enabled = true
	col.collide_with_bodies = true
	col.collision_mask = 1
	add_child(col)
	#print("Generating grass")
	var object_count = 0
	var last_update = 0
	#var next_update = object_count + object_per_loading_refresh
	var max_object_count = int((map_aabb.size.x/spacing) * (map_aabb.size.z/spacing))
	var current_loading_percentage = next_percentage_to_refresh

	if grass:
		@warning_ignore("integer_division")
		for x in range(-generator_size / 2, generator_size / 2,spacing):
			@warning_ignore("integer_division")
			for z in range(-generator_size / 2, generator_size / 2,spacing):
				var cur_variation = Vector3(randf_range(-grass_randomness*spacing, grass_randomness*spacing), 0, randf_range(-grass_randomness*spacing, grass_randomness*spacing))
				col.global_position = Vector3(x, maximum_height , z) + cur_variation
				col.target_position = Vector3(0, -(maximum_height - minimum_height), 0) + cur_variation
				col.force_raycast_update()
				if col.is_colliding():
					var grass_position = col.get_collision_point()
					var grass_normal = col.get_collision_normal()
					var random_rotation = randf_range(0, 2*PI)
					#print("Grass: ", grass_position, grass_normal, Vector3.ONE, random_rotation)
					if (grass_position.y > (minimum_height + abs((maximum_height - minimum_height) * min_height_percentage_grass))) and (grass_position.y < (minimum_height + abs((maximum_height - minimum_height) * max_height_percentage_grass))):
						grass.add_grass(grass_position, grass_normal, Vector3.ONE, random_rotation)
				object_count += 1
				var updated = loading.progressive_update(tree, object_count, max_object_count, int(current_loading_percentage * max_object_count) if use_percentage_loading else object_per_loading_refresh, last_update)
				if updated > last_update:
					last_update = updated
					await tree.process_frame
		loading.loading_text = "Finalisation... "
		await tree.process_frame
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
	var object_count = 0
	var last_update = 0
	#var next_update = object_count + object_per_loading_refresh
	var max_object_count = int((map_aabb.size.x/spacing) * (map_aabb.size.z/spacing))
	var current_loading_percentage = next_percentage_to_refresh
	if trees:
		for x in range(0,map_aabb.size.x,spacing):
			for z in range(0,map_aabb.size.z,spacing):
				var variation = Vector3(randf_range(-tree_randomness*spacing, tree_randomness*spacing), 0, randf_range(-tree_randomness*spacing, tree_randomness*spacing))
				col.global_position = Vector3(x, start_height + map_height,z) + variation
				col.target_position = Vector3(0, -map_height, 0)  + variation
				col.force_raycast_update()
				if col.is_colliding():
					var tree_position = (col.get_collision_point() if col.is_colliding() else Vector3(x, 0, z)) - Vector3(0, 0.33, 0)
					var tree_normal = col.get_collision_normal() if col.is_colliding() else Vector3.UP
					var random_rotation = randf_range(0, 2*PI)
					#print("Grass: ", grass_position, grass_normal, Vector3.ONE, random_rotation)
					trees.pick_random().instance().global_position = tree_position
				object_count += 1
				var updated = loading.progressive_update(get_tree(), object_count, max_object_count, int(current_loading_percentage * max_object_count) if use_percentage_loading else object_per_loading_refresh, last_update)
				if updated > last_update:
					last_update = updated
					await get_tree().process_frame
		if loading:
			loading.current = object_count
			loading.total = max_object_count
	else:
		push_error("Grass not found")
	await get_tree().process_frame
	remove_child(col)
	col.queue_free()
