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

var bois := preload("res://Item_Inventaire/Items/Bois.tres") as UniqueItem
var pierre := preload("res://Item_Inventaire/Items/Pierre.tres") as UniqueItem
var pioche_bois := preload("res://Item_Inventaire/Items/pioche_bois.tres") as UniqueItem

var player_main_object := 0
var player_inventaire = {}  # Utilisation d'un Dictionary

var inventaire_player : Array[ItemStack] = [
	ItemStack.new(bois, 10),
	ItemStack.new(pierre, 10),
	ItemStack.new(bois, 0),
	ItemStack.new(pierre, -1),
	ItemStack.new(bois, 2),
	ItemStack.new(pioche_bois,1)
]

var player_hotbar = [
	ItemStack.new(pioche_bois, 1),
]

var max_slots = 30
var stack = 64  # Quantité max par stack
var holded_item = null


func _ready() -> void:
	# Initialise l'inventaire avec des slots vides
	for i in range(max_slots):
		player_inventaire[i] = casse_vide.duplicate()


func player_inventair_give(loote: Dictionary):
	print(loote, len(player_inventaire))
	"""
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
	"""
