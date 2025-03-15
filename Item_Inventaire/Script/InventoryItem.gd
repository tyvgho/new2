class_name InventoryItem extends Resource

@export var item : UniqueItem
@export var quantity : int

func _init(_item : UniqueItem = null, _quantity : int = 0):
    if _item:
        self.item = _item
        self.quantity = _quantity