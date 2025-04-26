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
	inventory = value
	fullfil_slots(inventory, total_slots)
	refresh_gui()

func checkup_legal(items : Array[ItemStack]) -> Array[int]:
	var illegals = []
	for i_idx in range(len(items)):
		var item = items[i_idx]
		if item.item.stackable:
			if item.quantity > (item.item as UniqueItem).max_quantity or item.quantity < 1:
				illegals.append(i_idx)
		else:
			if item.quantity > 1 or item.quantity < 1:
				illegals.append(i_idx)
	return illegals

func _on_item_clicked(item : ItemStack, index : int, click_type : int = MOUSE_BUTTON_LEFT):
	if item.item == UniqueItem.get_empty_item() and Global.holded_item == null:
		empty_slot_clicked.emit(index)
	else:
		Global.holded_item = set_item_at_pos_clever(Global.holded_item if Global.holded_item != null else ItemStack.get_empty_item(), index, click_type)
	(get_child(index) as ItemSlot).update_item()

func refresh_gui():
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

func clear_inventory():
	inventory.resize(total_slots)
	for i in range(total_slots):
		inventory[i] = ItemStack.get_empty_item()
	refresh_gui()

## Equivalent of Shift+Click in Minecraft
func add_item_clever(item : ItemStack):
	# Looks in the inventory for a slot to add the item to, first looks if item already exists
	var quantity_remaining = item.quantity
	var max_quantity = (item.item as UniqueItem).max_quantity
	for child in get_children():
		child = (child as ItemSlot)
		if (child.assign_item.item as UniqueItem) == (item.item as UniqueItem):
			var max_quantity_to_deliver = max_quantity - child.assign_item.quantity
			if max_quantity_to_deliver <= 0:
				continue
			elif max_quantity_to_deliver > 0 and max_quantity_to_deliver < quantity_remaining:
				child.assign_item.quantity += max_quantity_to_deliver
				quantity_remaining -= max_quantity_to_deliver
			elif max_quantity_to_deliver > 0 and max_quantity_to_deliver >= quantity_remaining:
				child.assign_item.quantity += quantity_remaining
				quantity_remaining = 0
				return
	#If item wasn't found, add it
	add_item_dumb(item)

## Veryfies if the [item] exists in the [inventory]
static func verify_item_in_inventory(item : UniqueItem, _inventory : Array[ItemStack]) -> Array:
	var quantity = 0 # X
	var slots = []
	for i in range(_inventory.size()):
		if _inventory[i].item == item:
			quantity += _inventory[i].quantity
			slots.append(i)
	return slots

func remove_item_clever(item : ItemStack, quantity : int):
	# Looks in the inventory and try to remove the exact quantity from multiple slots until the remaining quantity to remove is 0 or there are no slot left
	var inv = verify_item_in_inventory(item.item, inventory)
	var quantity_remaining = quantity
	while quantity_remaining > 0 and inv.size() > 0:
		var slot = inv[0]
		var max_quantity = (slot.item as UniqueItem).max_quantity
		var max_quantity_to_deliver = max_quantity - slot.quantity
		if max_quantity_to_deliver <= 0:
			inv.remove_at(0)
		elif max_quantity_to_deliver > 0 and max_quantity_to_deliver < quantity_remaining:
			slot.quantity += max_quantity_to_deliver
			quantity_remaining -= max_quantity_to_deliver
		elif max_quantity_to_deliver > 0 and max_quantity_to_deliver >= quantity_remaining:
			slot.quantity += quantity_remaining
			quantity_remaining = 0

func add_item_dumb(item : ItemStack):
	# If item doesn't exist, add it
	for child in get_children():
		child = (child as ItemSlot)
		if child.assign_item == null:
			child.assign_item = item
			break

func set_item_at_pos(item : ItemStack, index : int):
	if index >= total_slots:
		return ERR_CANT_CREATE

	fullfil_slots(inventory, total_slots)
	inventory[index] = item
	get_child(index).assign_item = item
	refresh_gui()

## Sets item at the given position and returns the item that is held (= Global.holded_item)
func set_item_at_pos_clever(item : ItemStack, index : int, _action : int = MOUSE_BUTTON_LEFT):
	var quantity_remaining = item.quantity
	var max_quantity = (item.item as UniqueItem).max_quantity
	var slot = (get_child(index) as ItemSlot)

	if (slot.assign_item.item as UniqueItem) == (item.item as UniqueItem):
		## Maximum quantity of the item in the slot that can be delivered (how much you can but minus how much remaining to be a stack)
		var max_quantity_to_deliver = max_quantity - slot.assign_item.quantity
		if _action == MOUSE_BUTTON_LEFT:
			if max_quantity_to_deliver <= 0:
				return item
			elif max_quantity_to_deliver < quantity_remaining:
				slot.assign_item.quantity += max_quantity_to_deliver
				quantity_remaining -= max_quantity_to_deliver
				item.quantity -= max_quantity_to_deliver
				return item
			elif max_quantity_to_deliver >= quantity_remaining:
				slot.assign_item.quantity += quantity_remaining
				quantity_remaining = 0
				return ItemStack.get_empty_item()
		elif _action == MOUSE_BUTTON_RIGHT:
			if max_quantity_to_deliver <= 0:
				return item
			elif max_quantity_to_deliver > 0 and quantity_remaining > 0:
				slot.assign_item.quantity += 1
				quantity_remaining -= 1
				item.quantity -= 1
				return item

	else:
		# If empty slot and full hand, empty the hand to that slot
		if slot.assign_item == ItemStack.get_empty_item() and item != ItemStack.get_empty_item():
			if _action == MOUSE_BUTTON_RIGHT:
				slot.assign_item = item
				slot.assign_item.quantity = 1
				item.quantity -= 1
				return item
			elif _action == MOUSE_BUTTON_LEFT:
				slot.assign_item = item
			return ItemStack.get_empty_item()
		
		# If slot occupied but the hand is empty, pickup the item into the hand
		elif slot.assign_item != ItemStack.get_empty_item() and item == ItemStack.get_empty_item():
			if _action == MOUSE_BUTTON_LEFT:
				var item_to_return = slot.assign_item
				slot.assign_item = ItemStack.get_empty_item() # Empty Hand to slot
				return item_to_return
			elif _action == MOUSE_BUTTON_RIGHT: # Pickup half of the slot's item
				if slot.assign_item.quantity > 1:
					var slot_half_quantity = floori(slot.assign_item.quantity / 2)
					var hand_half_quantity = slot.assign_item.quantity - slot_half_quantity
					slot.assign_item.quantity = slot_half_quantity
					item = slot.assign_item
					item.quantity = hand_half_quantity
				return item

		# If slot not empty and hand not empty, swap
		elif slot.assign_item != ItemStack.get_empty_item() and item != ItemStack.get_empty_item():
			if _action == MOUSE_BUTTON_LEFT:
				var item_to_return = slot.assign_item
				slot.assign_item = item
				return item_to_return
			elif _action == MOUSE_BUTTON_RIGHT:
				return item
