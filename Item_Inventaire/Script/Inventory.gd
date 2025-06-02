class_name Inventory extends Resource

@export var name : String = "Inventory"
@export var items : Array[ItemStack]
@export var slots_quantity : int = 5*3

func _init(_items : Array[ItemStack], slots : int = 5*3):
	slots_quantity = slots
	items = _items
	repair_inventory()

func _to_string() -> String:
	return "{" + name + " : " + str(items) + "}"

func _ready():
	print_debug("Iter 1 : ",items[0])
	print_debug("Iter 2 : ",items[1])

func repair_inventory():
	items.resize(slots_quantity)
	for i in range(slots_quantity):
		if items[i] == null:
			items[i] = ItemStack.get_empty_item()

func is_empty() -> bool:
	return items.any(func(item) : return item != ItemStack.get_empty_item())

## Returns an Dictionary of keys : UniqueItems and values : Array of indexes of the items in inventory 
func inventory_to_dict() -> Dictionary[UniqueItem, Array]:
	var dict : Dictionary[UniqueItem, Array]= {}
	for i in range(slots_quantity):
		dict.get_or_add(items[i].item,[]).append(i)
	return dict


## Veryfies if the [item] exists in the [inventory]
func verify_item_in_inventory(item : UniqueItem) -> bool:
	return inventory_to_dict().has(item)

## Removes an ItemStack from the inventory, returns OK if item removed or ERR_CANT_RESOLVE if item not found or not enough
func remove_item_clever(item : ItemStack) -> Error:
	# Looks in the inventory for a slot to add the item to, first looks if item already exists
	for slot in items:
		if (slot.item as UniqueItem) == (item.item as UniqueItem):
			if item.quantity <= 0:
				return OK
			if slot.quantity - item.quantity >= 0: # If there is more of the item then in the slot
				slot.quantity -= item.quantity
				item.quantity = 0
			else: # Else if there is not enough in the slot
				item.quantity -= slot.quantity
				slot.quantity = 0
	print_debug("Inventory : ", self, " doesn't have enough item to remove ")
	return ERR_CANT_RESOLVE


func remove_items(i_to_remove : Array[ItemStack]):
	for itr in i_to_remove:
		remove_item_clever(itr)

func add_item_clever(item : ItemStack):
	# Looks in the inventory for a slot to add the item to, first looks if item already exists
	if inventory_to_dict().has(item.item):
		for slot in items:
			if (slot.item as UniqueItem) == (item.item as UniqueItem):
				if slot.quantity + item.quantity <= (slot.item as UniqueItem).max_quantity:
					slot.quantity += item.quantity
					return
				else:
					item.quantity = (slot.item as UniqueItem).max_quantity - slot.quantity
					slot.quantity = (slot.item as UniqueItem).max_quantity
	add_item_dumb(item)

## Add Item where slot's empty
func add_item_dumb(item : ItemStack) -> Error:
	for i in range(slots_quantity):
		if items[i].item == UniqueItem.get_empty_item(): #quand on fait get_empty_item() sa génére un item vide avec un identifien spésifique
			items[i] = item
			return OK
	return ERR_CANT_RESOLVE

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



# func remove_item_clever(item : ItemStack):
# 	# Looks in the inventory and try to remove the exact quantity from multiple slots until the remaining quantity to remove is 0 or there are no slot left
# 	var inv = Inventory.verify_item_in_inventory(item.item, inventory)
# 	var quantity_remaining = item.quantity
# 	while quantity_remaining > 0 and inv.size() > 0:
# 		var slot = inv[0]
# 		var max_quantity = (slot.item as UniqueItem).max_quantity
# 		var max_quantity_to_deliver = max_quantity - slot.quantity
# 		if max_quantity_to_deliver <= 0:
# 			inv.remove_at(0)
# 		elif max_quantity_to_deliver > 0 and max_quantity_to_deliver < quantity_remaining:
# 			slot.quantity += max_quantity_to_deliver
# 			quantity_remaining -= max_quantity_to_deliver
# 		elif max_quantity_to_deliver > 0 and max_quantity_to_deliver >= quantity_remaining:
# 			slot.quantity += quantity_remaining
# 			quantity_remaining = 0
