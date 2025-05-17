
class_name ItemStack extends Resource

@export var item : UniqueItem = UniqueItem.get_empty_item()
@export var quantity : int
@export var current_attributes : Dictionary = item.attributes


func _init(_item : UniqueItem = UniqueItem.get_empty_item(), _quantity : int = 0):
	if _item:
		self.item = _item
		self.quantity = _quantity

static func get_empty_item() -> ItemStack:
	return ItemStack.new(UniqueItem.get_empty_item(), 0)

static func get_items_in_itemstacks(itemstacks : Array[ItemStack]) -> Array[UniqueItem]:
	var uniqueitems : Array[UniqueItem] = []
	for item in itemstacks:
		uniqueitems.append(item.item)
	return uniqueitems
