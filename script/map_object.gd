extends StaticBody3D

@export_enum("pierre", "arbre") var objet_type : String
var obeject
var player_inventaire = Global.player_inventaire
var vie = 80 
var loote = ["",0]
var give_place := 0
const object = preload("res://scéne/entiter/itéme.tscn")

func  _ready() -> void:
	if objet_type == "pierre":
		loote = ["pierre",0]
	elif objet_type == "arbre":
		print(position)
		loote = ["boit",0]

func déga(nb):
	vie -= nb
	if vie >= 0:
		loote[1] = nb 
		var object_i = object.instantiate()
		add_child(object_i)
		object_i.initialize(loote[1],global_position+Vector3(0,5,0),loote[0])
		print(global_position,position)
	if vie <= 0:
		queue_free()


func new(area: Area3D) -> void:
	print(area.collision_layer)
	if area.collision_layer == 8:
		print("aa")
		déga(2)
