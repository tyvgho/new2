class_name InventoryItem extends Resource

@export var item : UniqueItem = UniqueItem.empty_item
@export var quantity : int

static var empty_item = InventoryItem.new(UniqueItem.empty_item, 0)

func _init(_item : UniqueItem = UniqueItem.empty_item, _quantity : int = 0):
    if _item:
        self.item = _item
        self.quantity = _quantity