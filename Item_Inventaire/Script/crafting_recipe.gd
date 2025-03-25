class_name Recipe extends Resource

@export var ingredients : Array[InventoryItem]
@export var result : InventoryItem

func is_valid() -> bool:
    if ingredients.is_empty():
        return false
    if result == null:
        return false
    return true

func has_all_items(inventory_to_check : Array[InventoryItem]) -> bool:
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