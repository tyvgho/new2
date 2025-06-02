## A class that contains ItemSlots and displays them in a grid, for the player's inventory or other inventories
class_name InventoryGUI extends GridContainer

## Signals called from ItemSlot children when clicked
signal item_clicked(item : ItemStack, index : int, click_type : int)
signal empty_slot_clicked(index : int)

@onready var slot_horizontal = columns
@export var slot_vertical = 3
@onready var total_slots = slot_horizontal * slot_vertical
@export var debug_mode : bool = true

@export var inventory : Array[ItemStack] = [] : set = _set_inventory
var item_slot = preload("res://Item_Inventaire/item_dans_inventaire.tscn")
var empty_item = preload("res://Item_Inventaire/Autre/item_vide.tres")

func _ready():
	#inventory = Global.inventaire_player
	#print(total_slots,"<->",get_child_count(),"<->",inventory.size())

	refresh_gui()
	item_clicked.connect(_on_item_clicked)

func _set_inventory(value : Array[ItemStack]):
	print("valeur",value)
	inventory = value
	fullfil_slots(inventory, total_slots)
	refresh_gui()



func _on_item_clicked(item : ItemStack, index : int, click_type : int = MOUSE_BUTTON_LEFT):
	if item.item == UniqueItem.get_empty_item() and Global.holded_item == null:
		empty_slot_clicked.emit(index)
	else:
		Global.holded_item = set_item_at_pos_clever(Global.holded_item if Global.holded_item != null else ItemStack.get_empty_item(), index, click_type)
	(get_child(index) as ItemSlot).update_item()

func refresh_gui():
	fullfil_slots(inventory,total_slots)
	for child in get_children():
		remove_child(child)
		child.queue_free()

	for i in range(total_slots):
		var slot = item_slot.instantiate()
		slot.assign_item = inventory[i] if i < inventory.size() else ItemStack.get_empty_item()
		add_child(slot)

func fullfil_slots(items : Array, max_slots: int):
	if items.size() != max_slots:
		items.resize(max_slots)
	for item in range(len(items)):
		if items[item] == null:
			items[item] = ItemStack.get_empty_item()



func set_item_at_pos(item : ItemStack, index : int):
	if index >= total_slots:
		return ERR_CANT_CREATE

	fullfil_slots(inventory, total_slots)
	inventory[index] = item
	get_child(index).assign_item = item
	refresh_gui()

## Sets item at the given position and returns the item that is held (= Global.holded_item)
