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
		item =  ItemStack.new(Global.pierre,quantiter)
		nb = 0
	elif item_type == "bois":
		item = ItemStack.new(Global.bois,quantiter)
		nb = 1
	elif item_type == "steak":
		loote = ItemStack.new(Global.viande,quantiter)
		nb = 2
	apparence.set_tree(nb)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
		move_and_slide()
	else :
		set_physics_process(false)

func recuper_item():
	# Récupérer l'inventaire du joueur
	var inventory_gui = get_tree().get_nodes_in_group("inventaire")
	if not inventory_gui.is_empty():
		for inv in inventory_gui:
			if inv is InventoryGUI:
				# Ajouter l'item à l'inventaire en utilisant add_item_clever
				inv.add_item_clever(item)
				print("Item ajouté à l'inventaire avec add_item_clever")
				break
	
	# Supprimer l'objet 3D après récupération
	queue_free()
