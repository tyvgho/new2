extends StaticBody3D
var obeject_type = ""
var sur_sol = false
var type = ""
@onready var modelle_obejt = $modelle_obejt


func _ready() -> void:
	var main_scene = get_tree().get_root().get_child(0)
	if not modelle_obejt or not modelle_obejt.mesh:
		print("Aucun mesh trouvé pour l'arbre.")
		return
	
	var collision_shape = CollisionShape3D.new()
	var collision_mesh = modelle_obejt.mesh.create_trimesh_shape() # Pour une collision concave

	collision_shape.shape = collision_mesh
	add_child(collision_shape)
	collision_shape.owner = self # Permet de le voir dans l'éditeur

func transfer_to_main_scene(node_to_transfer):
	var main_scene = get_tree().get_root().get_child(0) # Récupère la scène principale
	if node_to_transfer and main_scene:
		# Sauvegarde la position globale avant de changer de parent
		var global_pos = node_to_transfer.global_transform

		# Retire du parent actuel et ajoute à la scène principale
		node_to_transfer.get_parent().remove_child(node_to_transfer)
		main_scene.add_child(node_to_transfer)

		# Rétablit la position globale
		node_to_transfer.global_transform = global_pos

		# Ajuste la position pour qu'il touche le sol
		place_on_ground(node_to_transfer)

func place_on_ground(node):
	var space_state = get_world_3d().direct_space_state
	var from = node.global_transform.origin
	var to = from - Vector3(0, 10, 0) # Rayon de descente (10 unités en dessous)
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true # Permet de détecter les zones

	var result = space_state.intersect_ray(query)
	
	if result:
		# Place l'objet juste au-dessus du sol
		var new_pos = result.position
		new_pos.y += 0.1 # Légère élévation pour éviter d'être dans le sol
		node.global_transform.origin = new_pos

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("a"):
		transfer_to_main_scene(self) # On transfère ce nœud lui-même

func _on_area_3d_area_entered(area: Area3D) -> void:
	sur_sol = true

func _on_area_3d_area_exited(area: Area3D) -> void:
	sur_sol = false
func inisialise(obejet):
	type = obejet["name"]
	if type == "bois":
		$modelle_obejt.set_tree(0)
	elif type == "pierre":
		$modelle_obejt.set_tree(1)
	elif type == "table_craft":
		$modelle_obejt.set_tree(2)
