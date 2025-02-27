extends MeshInstance3D

@export var tree_meshes: Array[Mesh]  # Liste des Mesh d'arbres à assigner

var current_index: int = 0  # Index du modèle actuel

func _ready():
	if tree_meshes.size() > 0:
		set_tree(current_index) # Assigner le premier arbre au démarrage
		transform = Transform3D()  # Réinitialise la transformation
		scale = Vector3(1, 1, 1)  # Remet l’échelle à 1

# Fonction pour changer d’arbre
func set_tree(index: int):
	if index >= 0 and index < tree_meshes.size():
		mesh = tree_meshes[index]  # Change le modèle de l'arbre
		current_index = index  # Sauvegarde l'index actuel

# Fonction pour changer au prochain arbre dans la liste
func next_tree():
	var new_index = (current_index + 1) % tree_meshes.size()  # Boucle sur les arbres
	set_tree(new_index)

# Fonction pour changer à l’arbre précédent
func previous_tree():
	var new_index = (current_index - 1 + tree_meshes.size()) % tree_meshes.size()
	set_tree(new_index)
	
func _input(event):
	if event.is_action_pressed("ui_right"):  # Flèche droite
		next_tree()
	elif event.is_action_pressed("ui_left"):  # Flèche gauche
		previous_tree()
