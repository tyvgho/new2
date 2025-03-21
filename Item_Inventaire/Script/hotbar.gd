extends Control

@export var property : StringName

var _current_item_index = 0
var _current_item = InventoryItem.empty_item

@onready var items = []

func _ready():
	items.resize(5)
	items.fill(InventoryItem.new(UniqueItem.empty_item, 0))

func set_item_at_index(item : InventoryItem, index : int):
	items[index] = item

func get_item_at_index(index : int):
	return items[index]

func get_items():
	return items

func remove_item_at_index(index : int):
	items[index] = InventoryItem.new(UniqueItem.empty_item, 0)

func refresh_gui():
	for i in range(len(items)):
		var item = items[i]
		var slot = get_child(i)
		slot.assign_item = item
