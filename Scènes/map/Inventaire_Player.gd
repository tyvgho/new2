extends Node2D

# Références globales et constantes
var case_vide = {"name": "", "count": 0}
var grille_cases := []  # Stocke la grille des cases
var case_selectionnee = [0, 0]  # Position de la case actuellement sélectionnée
var position_pixel_reference = Vector2(45, 45)  # Point d'ancrage pour la grille
var inventaire_joueur = Global.player_inventaire  # Référence à l'inventaire du joueur
const ObjetScene = preload("res://animated_sprite_2d.tscn")
var index_inventaire := 0
var objet_selectionne = null
var barre_rapide = Global.player_aute_bar  # Barre d'accès rapide du joueur

# Définition des ressources nécessaires pour crafter la table de craft
const COUT_CRAFT_TABLE = {"bois": 4, "pierre": 1}
const OBJET_TABLE_CRAFT = {"name": "table_craft", "count": 1}

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	position = position_pixel_reference
	initialiser_grille(6, 5)
	remplir_grille_depuis_inventaire()

# Initialise la grille avec un nombre de colonnes et de lignes
func initialiser_grille(nb_lignes: int, nb_colonnes: int) -> void:
	var compteur = 0
	for i in range(nb_lignes):
		grille_cases.append([])
		for j in range(nb_colonnes):
			grille_cases[i].append(compteur)
			compteur += 1

# Remplit la grille en fonction de l'inventaire du joueur
func remplir_grille_depuis_inventaire() -> void:
	index_inventaire = 0
	for i in range(6):
		for j in range(5):
			if inventaire_joueur.has(index_inventaire) and inventaire_joueur[index_inventaire]["name"] != "":
				if inventaire_joueur[index_inventaire]["count"] > 0:
					case_selectionnee = [i, j]
					ajouter_objet(Vector2(i, j), index_inventaire)
				else:
					inventaire_joueur[index_inventaire] = case_vide

			index_inventaire += 1
# Ajoute un objet à la position donnée dans la grille
func ajouter_objet(position_case: Vector2, index: int) -> void:
	var position_pixel = convertir_case_en_pixel(position_case)
	var nouvel_objet = ObjetScene.instantiate()
	add_child(nouvel_objet)
	nouvel_objet.initialize(position_pixel, inventaire_joueur[index])
	nouvel_objet.connect("objet_deplace", Callable(self, "_on_objet_deplace"))

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("move-right"):
		crafter_table()
	if Input.is_action_just_pressed("ui_down"):
		deplacer_vers_barre_rapide(get_global_mouse_position())

# Crée une table de craft si le joueur a les ressources nécessaires
func crafter_table() -> void:
	if possede_ressources(COUT_CRAFT_TABLE):
		supprimer_ressources(COUT_CRAFT_TABLE)
		ajouter_a_inventaire(OBJET_TABLE_CRAFT)
		print("Table de craft créée !")
	else:
		print("Pas assez de ressources pour créer une table de craft.")

# Vérifie si l'inventaire contient suffisamment de ressources
func possede_ressources(ressources_requises: Dictionary) -> bool:
	var compte_ressources = {"bois": 0, "pierre": 0}
	for item in inventaire_joueur.values():
		if item["name"] in compte_ressources:
			compte_ressources[item["name"]] += item["count"]

	for ressource in ressources_requises.keys():
		if compte_ressources[ressource] < ressources_requises[ressource]:
			return false
	return true

# Retire les ressources nécessaires de l'inventaire
func supprimer_ressources(ressources_requises: Dictionary) -> void:
	var ressources_a_retirer = ressources_requises.duplicate()

	for i in inventaire_joueur.keys():
		var item = inventaire_joueur[i]
		if item["name"] in ressources_a_retirer and ressources_a_retirer[item["name"]] > 0:
			var quantite_a_retirer = min(ressources_a_retirer[item["name"]], item["count"])
			item["count"] -= quantite_a_retirer
			ressources_a_retirer[item["name"]] -= quantite_a_retirer
			if item["count"] <= 0:
				inventaire_joueur[i] = case_vide.duplicate()

# Ajoute un nouvel objet à l'inventaire
func ajouter_a_inventaire(nouvel_objet: Dictionary) -> void:
	for i in inventaire_joueur.keys():
		if inventaire_joueur[i]["name"] == "":
			inventaire_joueur[i] = nouvel_objet.duplicate()
			ajouter_objet(convertir_pixel_en_case(Vector2(45, 45)), i)
			replace_element()
			return

# Déplace un objet vers la barre rapide
func deplacer_vers_barre_rapide(position_souris: Vector2) -> void:
	var case_cible = convertir_pixel_en_case(position_souris)
	var x = case_cible.x
	var y = case_cible.y
	var index_objet = grille_cases[x][y]

	ajouter_a_barre_rapide(inventaire_joueur[index_objet])
	inventaire_joueur[index_objet] = case_vide.duplicate()

# Ajoute un objet dans la barre rapide
func ajouter_a_barre_rapide(objet: Dictionary) -> void:
	for i in range(barre_rapide.size()):
		if barre_rapide[i]["name"] == "":
			barre_rapide[i] = objet.duplicate()
			return

# Convertit une position en case vers une position en pixel
func convertir_case_en_pixel(case: Vector2) -> Vector2:
	return Vector2(45 + case.x * 115, 45 + case.y * 100)

# Convertit une position en pixel vers une position en case
func convertir_pixel_en_case(position: Vector2) -> Vector2:
	position -= Vector2(45, 45)
	return Vector2(int(position.x / 115), int(position.y / 100))

# Gère le déplacement de l'objet lorsqu'il est lâché
func _on_objet_deplace(objet, nouvelle_position, ancienne_position) -> void:
	var nouvelle_case = convertir_pixel_en_case(nouvelle_position)
	var ancienne_case = convertir_pixel_en_case(ancienne_position)
	var x = nouvelle_case[0]
	var y = nouvelle_case[1]
	var old_x = ancienne_case[0]
	var old_y = ancienne_case[1]

	if inventaire_joueur[grille_cases[x][y]]["name"] == "":
		barre_rapide = []
		inventaire_joueur[grille_cases[old_x][old_y]] = case_vide.duplicate()
		inventaire_joueur[grille_cases[x][y]] = objet
		for index in grille_cases[5]:
			if index > 24:
				barre_rapide.append(inventaire_joueur[index])
		Global.player_aute_bar = barre_rapide
		print(Global.player_aute_bar, barre_rapide)
	
	replace_element()

func replace_element():
	for child in get_children():
		if child is AnimatedSprite2D:
			remove_child(child)
			child.queue_free()
	remplir_grille_depuis_inventaire()
