## Script qui gère l'inventaire du joueur et de HUD des éléments comme la table de craft
class_name PlayerInventory extends Control

var bois = preload("res://Item_Inventaire/Items/Bois.tres")
var pierre = preload("res://Item_Inventaire/Items/Pierre.tres")

var inventory = Global.inventaire_player : set = _set_inventory

var total_slots = 5*3
@export var holded_item_instance : Item_Preview = preload("res://Item_Inventaire/hovered_item.tscn").instantiate()
@export var anim : AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(holded_item_instance)
	var inventory_grids = get_tree().get_nodes_in_group("inventaire")
	for inv in inventory_grids:
		(inv as InventoryGUI).item_clicked.connect(_on_item_clicked)
		inv.inventory = inventory
		inv.refresh_gui()
	#_set_inventory(inventory)

func _set_inventory(value):
	inventory = value
	for inv in get_tree().get_nodes_in_group("inventaire"):
		inv.inventory = inventory
		inv.refresh_gui()

func _on_item_clicked(item : InventoryItem, _index : int, _click_type : int = MOUSE_BUTTON_LEFT):
	%InvItemName.text = item.item.name
	%InvItemDesc.text = item.item.description

func _process(_delta):
	if holded_item_instance:
		holded_item_instance.visible = Global.holded_item != null
		holded_item_instance.item = Global.holded_item

	if Input.is_action_just_pressed("e"):
		if visible:
			anim.play("hide")
		else:
			anim.play("show")
