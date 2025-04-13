class_name ItemStack extends Resource

@export var item : UniqueItem = UniqueItem.get_empty_item()
@export var quantity : int
@export var current_attributes : Dictionary = item.attributes

static func get_empty_item() -> ItemStack:
	return ItemStack.new(UniqueItem.get_empty_item(), 0)

func _init(_item : UniqueItem = UniqueItem.get_empty_item(), _quantity : int = 0):
	if _item:
		self.item = _item
		self.quantity = _quantity
