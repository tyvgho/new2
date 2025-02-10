extends Node2D

var casse_vide = Global.casse_vide
var tableaux := []
var casse_selectionnee = [0, 0]
var pixel_haut_gauche = Vector2(0, 0)
var object_in = Global.player_inventaire
const object = preload("res://animated_sprite_2d.tscn")
var c := 0
var item_selectionne = null

# Définition des ressources nécessaires pour crafter la table de craft
const COUT_CRAFT_TABLE = {"boit": 5, "pierre": 1}
const TABLE_CRAFT = ["table_craft",1]

func _ready() -> void:
	position = Vector2(45, 45)
	for i in range(5):
		tableaux.append([0, 0, 0, 0, 0])
	for i in range(5):
		for j in range(5):
			if object_in[c] == casse_vide:
				pass
			else:
				casse_selectionnee = [i, j]
				add_object(Vector2(i, j), c)
			c += 1

func add_object(casse, c):
	var pixel_postion = convertion_casse_2_pixel(casse)
	var object_i = object.instantiate()
	add_child(object_i)
	object_i.initialize(object_in[c][1], pixel_postion, object_in[c][0])

func _input(event: InputEvent) -> void:
	if item_selectionne and event is InputEventMouseMotion:
		item_selectionne.global_position = get_global_mouse_position()
	elif event is InputEventMouseButton and not event.pressed:
		if item_selectionne:
			var nouvelle_casse = convertion_pixel_2_casse(item_selectionne.global_position)
			print("Nouvelle case : ", nouvelle_casse)
			item_selectionne = null
	elif Input.is_action_just_pressed("e"):
		craft_table()

func craft_table():
	if possede_ressources(COUT_CRAFT_TABLE):
		retirer_ressources(COUT_CRAFT_TABLE)
		ajouter_objet(TABLE_CRAFT)
		print("Table de craft créée !")
	else:
		print("Pas assez de ressources pour créer une table de craft.")

func possede_ressources(ressources_requises: Dictionary) -> bool:
	var inventaire_count = {"boit": 0, "pierre": 0}
	for item in object_in :
		if item[0] in inventaire_count:
			inventaire_count[item[0]] += item[1]
	
	for ressource in ressources_requises.keys():
		print("zz",ressource)
		if inventaire_count[ressource] < ressources_requises[ressource]:
			return false
	return true

func retirer_ressources(ressources_requises: Dictionary):
	var a_retirer = ressources_requises.duplicate()  # Copie pour ne pas modifier l'original

	for i in range(object_in.size()):
		var item = object_in[i]

		if item[0] in a_retirer and a_retirer[item[0]] > 0:  # Vérifie si l'objet est requis
			var quantite_a_retirer = min(a_retirer[item[0]], item[1])  # Retirer la quantité nécessaire, mais pas plus que ce que l'on possède
			item[1] -= quantite_a_retirer  # Réduit la quantité dans l'inventaire
			a_retirer[item[0]] -= quantite_a_retirer  # Met à jour la quantité à retirer
			if item[1] <= 0:  # Si l'objet n'a plus de quantité, on le remplace par une case vide
				object_in[i] = casse_vide


func ajouter_objet(nouvel_objet: Array):
	for i in range(object_in.size()):
		if object_in[i] == casse_vide:
			object_in[i] = nouvel_objet
			add_object(convertion_pixel_2_casse(Vector2(45, 45)), i)
			return

func convertion_casse_2_pixel(casse):
	var pixel = Vector2(45, 45)
	pixel.x += casse.x * 115
	pixel.y += casse.y * 100
	print(casse,pixel)
	return pixel

func convertion_pixel_2_casse(coredone):
	var casse = Vector2(0, 0)
	coredone -= Vector2(45, 45)
	casse.x = int(coredone.x / 115)
	casse.y = int(coredone.y / 100)
	return casse
