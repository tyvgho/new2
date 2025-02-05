extends StaticBody3D

@export_enum("pierre", "arbre") var objet_type : String
var obeject
var player_inventaire = Global.player_inventaire
var vie = 80 
var loote = ["",0]
var give_place := 0

func  _ready() -> void:
	if objet_type == "pierre":
		loote = ["pierre",0]
	elif objet_type == "arbre":
		loote = ["boit",0]

func déga(nb):
	vie -= nb
	if vie >= 0:
		loote[1] = nb 
		Global.player_invetér_give(loote)
	if vie <= 0:
		queue_free()


func new(area: Area3D) -> void:
	print("aa")
	déga(2)
