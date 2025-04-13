## The player hotbar, where the player can switch between items and that's the only thing it does
class_name Hotbar extends Control
## e
@export var property : StringName

var _current_item_index = 0
var _current_item = null

@onready var items : Array[ItemStack] = []

func _ready():
	items.resize(5)

func set_item_at_index(item : ItemStack, index : int):
	if item == null:
		items[index] = ItemStack.get_empty_item()
	else:
		items[index] = item

func get_item_at_index(index : int):
	var item_to_return = items[index] if items[index] != null else ItemStack.get_empty_item()
	return item_to_return

func select_item_at_index(index : int) -> ItemStack:
	(get_child(index) as ItemSlot).grab_focus()
	_current_item_index = index
	_current_item = get_item_at_index(index)
	return _current_item

func select_next_item() -> ItemStack:
	return select_item_at_index((_current_item_index + 1) % items.size())

func select_previous_item() -> ItemStack:
	return select_item_at_index((_current_item_index - 1) % items.size())

func refresh_gui():
	for i in range(len(items)):
		var item = items[i]
		var slot = get_child(i)
		slot.assign_item = item
