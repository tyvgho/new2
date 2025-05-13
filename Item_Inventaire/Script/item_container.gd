class_name ItemContainer extends Resource

@export var items : Array[ItemStack]
@export var container_size : int :
    set(value):
        container_size = value
        items.resize(value)
    get:
        return container_size

func repair_inventory():
    items.resize(container_size)
    for i in range(container_size):
        if items[i] == null:
            items[i] = ItemStack.get_empty_item()

func is_empty() -> bool:
    return items.is_empty()

func get_size() -> int:
    return items.size()

func get_item(index : int) -> ItemStack:
    return items[index]

func get_unique_items() -> Array[UniqueItem]:
    var unique_items = []
    for item in items:
        if unique_items.has(item.item):
            continue
        unique_items.append(item.item)
    return unique_items