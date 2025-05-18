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
var viande := preload("res://Item_Inventaire/Items/viande.tres") as UniqueItem

var player_main_object := 0

var inventaire_player : Array[ItemStack] = [
# 	ItemStack.new(bois, 10),
# 	ItemStack.new(pierre, 10),
# 	ItemStack.new(bois, 0),
# 	ItemStack.new(pierre, -1),
# 	ItemStack.new(bois, 2),
# 	ItemStack.new(pioche_bois,1),
# 	ItemStack.new(bois, 10)
]

var player_hotbar = [
	ItemStack.new(pioche_bois, 1),
]

var max_slots = 30
var stack = 64  # Quantité max par stack
var holded_item = null


func _ready() -> void:
	pass

