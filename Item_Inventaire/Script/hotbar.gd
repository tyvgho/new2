## The player hotbar, where the player can switch between items and that's the only thing it does
class_name Hotbar extends Control
## e
@export var property : StringName

var _current_item_index = 0
var _current_item = null

@onready var items : Array[InventoryItem] = []

func _ready():
	items.resize(5)
	items.fill(null)

func set_item_at_index(item : InventoryItem, index : int):
	if item == null:
		items[index] = InventoryItem.new(UniqueItem.empty_item, 0)
	else:
		items[index] = item

func get_item_at_index(index : int):
	var item_to_return = items[index] if items[index] != null else InventoryItem.new(UniqueItem.empty_item, 0)
	return item_to_return

func select_item_at_index(index : int) -> InventoryItem:
	(get_child(index) as ItemSlot).grab_focus()
	_current_item_index = index
	_current_item = get_item_at_index(index)
	return _current_item

func select_next_item() -> InventoryItem:
	return select_item_at_index((_current_item_index + 1) % items.size())

func select_previous_item() -> InventoryItem:
	return select_item_at_index((_current_item_index - 1) % items.size())

func refresh_gui():
	for i in range(len(items)):
		var item = items[i]
		var slot = get_child(i)
		slot.assign_item = item
