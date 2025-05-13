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
	if has_all_items(inventory_to_check):
		for index in range(inventory_to_check).size():
			var item = inventory_to_check[index]

			if item.quantity >= aquisition[0].quantity:
				item.quantity -= aquisition[0].quantity
				aquisition.remove_at(0)
