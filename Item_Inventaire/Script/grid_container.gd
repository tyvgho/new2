## A class that contains ItemSlots and displays them in a grid, for the player's inventory or other inventories
class_name InventoryGUI extends GridContainer

## Signals called from ItemSlot children when clicked
signal item_clicked(item : InventoryItem, index : int, click_type : int)
signal empty_slot_clicked(index : int)

@onready var slot_horizontal = columns
@export var slot_vertical = 3
@onready var total_slots = slot_horizontal * slot_vertical

@export var inventory = [] : set = _set_inventory
const item_slot = preload("res://Item_Inventaire/item_dans_inventaire.tscn")
const empty_item = preload("res://Item_Inventaire/Autre/item_vide.tres")

func _ready():
	inventory = Global.inventaire_player
	print(total_slots,"<->",get_child_count(),"<->",inventory.size())

	refresh_gui()
	item_clicked.connect(_on_item_clicked)

func _set_inventory(value):
	inventory = value
	fullfil_slots(inventory, total_slots)
	refresh_gui()

func _on_item_clicked(item : InventoryItem, index : int, click_type : int = MOUSE_BUTTON_LEFT):
	
	if item.item == UniqueItem.empty_item and Global.holded_item == null:
		empty_slot_clicked.emit(index)
	else:
		Global.holded_item = set_item_at_pos_clever(Global.holded_item if Global.holded_item != null else InventoryItem.empty_item, index)
	(get_child(index) as ItemSlot).update_item()
	# # Si le joueur ne tiens pas d'item
	# if item.item == UniqueItem.empty_item:
	# 	if Global.holded_item != null:
	# 		set_item_at_pos(Global.holded_item, index)
	# 		Global.holded_item = null
	# # Si il tient quelque chose
	# elif item.item != UniqueItem.empty_item and Global.holded_item == null:
	# 	Global.holded_item = item
	# 	set_item_at_pos(InventoryItem.new(UniqueItem.empty_item, 0), index)

	# # Si il tient quelque chose et que le slot est occupé
	# elif item.item != UniqueItem.empty_item and Global.holded_item != null:
	# 	var holded_item = Global.holded_item
	# 	Global.holded_item = item
	# 	set_item_at_pos(holded_item, index)
	
	# # Si il tient rien et que le slot est vide
	# else:
	# 	empty_slot_clicked.emit(index)

func refresh_gui():
	for child in get_children():
		remove_child(child)
		child.queue_free()

	for i in range(total_slots):
		var slot = item_slot.instantiate()
		slot.assign_item = inventory[i] if i < inventory.size() else InventoryItem.new(UniqueItem.empty_item, 0)
		add_child(slot)

func fullfil_slots(items : Array, max_slots: int):
	if items.size() != max_slots:
		items.resize(max_slots)
		for item in range(len(items)):
			if items[item] == null:
				items[item] = InventoryItem.new(UniqueItem.empty_item, 0)
			

func clear_inventory():
	inventory.resize(total_slots)
	for i in range(total_slots):
		inventory[i] = InventoryItem.new(UniqueItem.empty_item, 0)
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

func set_item_at_pos(item : InventoryItem, index : int):
	if index >= total_slots:
		return ERR_CANT_CREATE

	fullfil_slots(inventory, total_slots)
	inventory[index] = item
	get_child(index).assign_item = item
	refresh_gui()

func set_item_at_pos_clever(item : InventoryItem, index : int):
	var quantity_remaining = item.quantity
	var max_quantity = (item.item as UniqueItem).max_quantity
	var slot = get_child(index)
	if (slot.assign_item.item as UniqueItem) == (item.item as UniqueItem):
		var max_quantity_delivered = max_quantity - slot.assign_item.quantity
		if max_quantity_delivered <= 0:
			return item
		elif max_quantity_delivered > 0 and max_quantity_delivered < quantity_remaining:
			slot.assign_item.quantity += max_quantity_delivered
			quantity_remaining -= max_quantity_delivered
			item.quantity -= max_quantity_delivered
			return item
		elif max_quantity_delivered > 0 and max_quantity_delivered >= quantity_remaining:
			slot.assign_item.quantity += quantity_remaining
			quantity_remaining = 0
			return InventoryItem.empty_item
	else:
		if slot.assign_item == InventoryItem.empty_item:
			slot.assign_item = item
			return InventoryItem.empty_item
		else:
			var item_to_return = slot.assign_item
			slot.assign_item = item
			return item_to_return
