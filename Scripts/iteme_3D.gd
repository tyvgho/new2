class_name ItemDrop
extends CharacterBody3D

var item_type = ""
var loote
var quantiter = 0
var nb = 0

@export var item : ItemStack 
@onready var apparence = $modelle_arbre

func initialize(nouveau_nombre, new_position, new_type):
	self.item_type = new_type
	self.quantiter = nouveau_nombre
	self.position = new_position

	if item_type == "pierre":
		loote = {"name": "pierre", "count": quantiter}
		nb = 0
	elif item_type == "bois":
		loote = {"name": "bois", "count": quantiter}
		nb = 1
	elif item_type == "steak":
		loote = {"name": "steak", "count": quantiter}
		nb = 2
	apparence.set_tree(nb)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		move_and_slide()
	else :
		set_physics_process(false)

func recuper_item():
	Global.inventaire_player
	queue_free()
