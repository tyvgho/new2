
## A class that contains ItemSlots and displays them in a grid, for the player's inventory or other inventories
class_name InventoryGUI extends GridContainer

## Signals called from ItemSlot children when clicked
signal item_clicked(item : InventoryItem, index : int)
signal empty_slot_clicked(index : int)

@onready var slot_horizontal = (self as GridContainer).columns
@export var slot_vertical = 4
var total_slots = slot_horizontal * slot_vertical

@export var inventory = []
const item_slot = preload("res://Item_Inventaire/item_dans_inventaire.tscn")
const empty_item = preload("res://Item_Inventaire/Autre/item_vide.tres")

func refresh_gui():
	for c_idx in self.get_child_count():
		var child = (self.get_child(c_idx) as ItemSlot)
		child.assign_item = inventory[c_idx]

func clear_inventory():
	inventory.resize(total_slots)
	for i in range(total_slots):
		inventory[i] = InventoryItem.new(empty_item, 0)
	refresh_gui()

## Equivalent of Shift+Click in Minecraft
func add_item_clever(item : InventoryItem):
	# Looks in the inventory for a slot to add the item to, first looks if item already exists
	var quantity_remaining = item.quantity
	var max_quantity = (item.item as UniqueItem).max_quantity
	for child in get_children():
		child = (child as ItemSlot)
		if (child.assign_item.item as UniqueItem) == (item.item as UniqueItem):
			var max_quantity_delivered = max_quantity - child.assign_item.quantity
			if max_quantity_delivered <= 0:
				continue
			elif max_quantity_delivered > 0 and max_quantity_delivered < quantity_remaining:
				child.assign_item.quantity += max_quantity_delivered
				quantity_remaining -= max_quantity_delivered
			elif max_quantity_delivered > 0 and max_quantity_delivered >= quantity_remaining:
				child.assign_item.quantity += quantity_remaining
				quantity_remaining = 0
				return

	#If item wasn't found, add it
	add_item_dumb(item)	

func add_item_dumb(item : InventoryItem):
	# If item doesn't exist, add it
	for child in get_children():
		child = (child as ItemSlot)
		if child.assign_item == null:
			child.assign_item = item
			break

func set_item_at_pos(item, x, y):
	if x >= slot_horizontal or y >= slot_vertical:
		return ERR_CANT_CREATE
	
	var final_index = y * slot_horizontal + x

	inventory[final_index] = item
