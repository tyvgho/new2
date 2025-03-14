extends Node

var player_potion = Vector3.ZERO
var player_vie = 20
var player_is_attacking := false

var casse_vide = {"name": "", "count": 0}
var player_aute_bar := [
	{"name": "", "count": 0},
	{"name": "", "count": 0},
	{"name": "", "count": 0},
	{"name": "", "count": 0},
	{"name": "", "count": 0}
]

var player_main_object := 0
var player_inventaire = {}  # Utilisation d'un Dictionary
var max_slots = 30
var stack = 64  # Quantité max par stack

func _ready() -> void:
	# Initialise l'inventaire avec des slots vides
	for i in range(max_slots):
		player_inventaire[i] = casse_vide.duplicate()

func player_inventaire_give(loote: Dictionary):
	print(loote, len(player_inventaire))

	var found = false
	var give_place = -1

	# Vérifie si l'objet est déjà dans l'inventaire et peut être stacké
	for i in range(max_slots):
		if player_inventaire[i]["name"] == loote["name"] and player_inventaire[i]["count"] < stack:
			var new_count = player_inventaire[i]["count"] + loote["count"]
			player_inventaire[i]["count"] = min(new_count, stack)  # Ne dépasse pas la limite du stack
			found = true
			break
		elif player_inventaire[i]["name"] == "":  # Trouver un slot vide
			give_place = i

	# Si l'objet n'a pas été ajouté à un stack existant, ajoute-le à un slot vide
	if not found and give_place != -1:
		player_inventaire[give_place] = loote.duplicate()

	print("Inventaire mis à jour:", player_inventaire)
