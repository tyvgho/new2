## Script qui gère l'inventaire du joueur et de HUD des éléments comme la table de craft
class_name PlayerInventory extends Control

var inventory = [] : set = _set_inventory
@export var anim : AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _set_inventory(value):
	inventory = value
	update_inventory()

func update_inventory():
	# Get all node of the group inventory
	var inventory_grids = get_tree().get_nodes_in_group("inventory")
	for inv in inventory_grids:
		inv = (inv as GridContainer)
		inv.clear()
		for item in inventory:
			inv.add_child(item)

func _process(delta):
	if Input.is_action_just_pressed("e"):
		if visible:
			anim.play("hide")
		else:
			anim.play("show")
