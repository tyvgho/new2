class_name Recipe extends Resource

enum RECIPE_TYPE {CRAFTING, SMELTING, FORGING, ENCHANTING}

@export var ingredients : Array[ItemStack]
@export var result : ItemStack
@export var type : RECIPE_TYPE

func is_valid() -> bool:
	if self.ingredients.is_empty():
		return false
	if self.result == null or self.result != ItemStack.get_empty_item():
		return false
	return true

func has_all_items(inventory_to_check : Array[ItemStack]) -> bool:
	var aquisition = []
	for ingredient in ingredients:
		var slots = InventoryGUI.verify_item_in_inventory(ingredient.item, inventory_to_check)
		if slots.is_empty():
			return false
		for slot in slots:
			if slot.quantity < ingredient.quantity:
				return false
			aquisition.append(inventory_to_check[slot])
	return true

## Consume the items in the inventory following the recipe
func consume_items(inventory_to_check : Array[ItemStack]):
	var aquisition = ingredients.duplicate()
	var aquisition_uitems = ItemStack.get_items_in_itemstacks(aquisition)
	var inventory_uitems = ItemStack.get_items_in_itemstacks(inventory_to_check)
	if has_all_items(inventory_to_check):
		for inv_idx in range(inventory_uitems):
			var inv_uitem = inventory_uitems[inv_idx]
			for aqu_idx in range(aquisition_uitems):
				var aqu_uitem = aquisition_uitems[inv_idx]
				if inv_uitem == aqu_uitem:
					if inventory_to_check[inv_idx].quantity < aquisition[aqu_idx].quantity:
						aquisition[aqu_idx] -= inventory_to_check[inv_idx]
						inventory_to_check[inv_idx] = ItemStack.get_empty_item()
					else:
						inventory_to_check[inv_idx] -= aquisition[aqu_idx] 
						aquisition.remove_at(aqu_idx)
						
			
			
