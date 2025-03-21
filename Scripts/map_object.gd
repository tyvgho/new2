class_name Generator extends StaticBody3D

@export_enum("pierre", "arbre") var objet_type: String
@export var vie: int = 80  # Permet d'éditer la vie directement dans l'inspecteur

var player_inventaire = Global.player_inventaire
var loote = {"name":"", "count": 0}  # Initialisation correcte
#const OBJECT_SCENE = preload("res://Scènes/entiter/itéme.tscn")
@export var OBJECT_SCENE : PackedScene = load("res://Scènes/entiter/itéme.tscn")

func _ready() -> void:
	# Initialise le loot en fonction du type d'objet
	if objet_type == "pierre":
		loote = {"name": "pierre", "count": 5}
	elif objet_type == "arbre":
		loote = {"name": "bois", "count": 5}  # Correction ici

# Applique des dégâts à l'objet
func déga(nb: int) -> void:
	print(loote)
	vie -= nb
	if vie > 0:
		print("z")
		# Crée un objet looté à chaque coup
		loote["count"] = nb  # Ajuste la quantité lootée
		var object_instance = OBJECT_SCENE.instantiate()
		get_parent().add_child(object_instance)  # Ajout correct dans la scène principale
		object_instance.initialize(loote["count"], global_position + Vector3(0, 5, 0),loote["name"])
	else:
		# Détruit l'objet quand sa vie tombe à 0
		queue_free()
