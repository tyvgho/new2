extends Node3D
const construction = preload("res://Scènes/map/Objet/Objet_drop.tscn")
var o = false
var main_obejet = Global.player_main_object
var bar_rapide = Global.player_aute_bar
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("a") and not o and Global.player_aute_bar[Global.player_main_object]["name"] != "":
		var construction_i = construction.instantiate()
		add_child(construction_i)
		construction_i.inisialise(Global.player_aute_bar[Global.player_main_object])
		var item = Global.player_aute_bar[Global.player_main_object] # Récupérer une copie du sous-tableau
		item["count"] -= 1  # Modifier la quantité de l'objet
		if item["count"] <= 0 :
			Global.player_aute_bar[Global.player_main_object] = Global.casse_vide
			print(Global.player_aute_bar)
			o = false
		else :
			Global.player_aute_bar[Global.player_main_object]["count"] = item["count"]  # Réassigner la nouvelle valeur
		o = true
	else :
		o = false
