extends MeshInstance3D

@export var balle : RigidBody3D

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
	noise.seed = randi()
	noise.fractal_octaves = 6
	noise.fractal_lacunarity = 2.0
	noise.fractal_gain = 0.5

	generate_terrain()

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
