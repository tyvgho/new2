## Script qui gère l'inventaire du joueur et de HUD des éléments comme la table de craft
class_name PlayerInventory extends Control

var inventory = Global.inventaire_player : set = _set_inventory

@export var holded_item_instance : Item_Preview = preload("res://Item_Inventaire/held_item.tscn").instantiate()
@export var anim : AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(holded_item_instance)
	var inventory_grids = get_tree().get_nodes_in_group("inventaire")
	if inventory_grids.is_empty():
		return
	for inv in inventory_grids:
		if inv is InventoryGUI:
			inv.item_clicked.connect(_on_item_clicked)
			inv.inventory = inventory
			inv.refresh_gui()
		else:
			push_error("InventoryGUI not found")
	#_set_inventory(inventory)

func _set_inventory(value):
	inventory = value
	for inv in get_tree().get_nodes_in_group("inventaire"):
		inv.inventory = inventory
		inv.refresh_gui()

func _on_item_clicked(item : ItemStack, _index : int, _click_type : int = MOUSE_BUTTON_LEFT):
	$"PanelContainer/TabContainer/Table de Craft/Control/PanelContainer2/MarginContainer/VBoxContainer/Label".text = item.item.name if item.item else ""
	$"PanelContainer/TabContainer/Table de Craft/Control/PanelContainer2/MarginContainer/VBoxContainer/Label2".text = item.item.description if item.item else ""

func _process(_delta):
	if holded_item_instance:
		holded_item_instance.visible = Global.holded_item != null
		holded_item_instance.item = Global.holded_item

func open_inventory(_tab : int = 0):
	anim.play("show")

func close_inventory():
	anim.play("hide")
