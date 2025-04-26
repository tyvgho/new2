@icon("res://Item_Inventaire/Icon/ItemStackIcon.svg")
class_name UniqueItem extends Resource

enum ItemType{
    None,
    Building,
    Consumable,
    Material,
    Tool,
    Weapon,
    Armor
}

@export var texture : Texture2D;
@export var name : String;
@export var description : String;
@export var stackable : bool = false
@export var max_quantity : int;
@export var item_id : StringName;
@export var flags : ItemType = ItemType.None
@export var attributes : Dictionary = {};

static func get_empty_item() -> UniqueItem:
    return UniqueItem.new(&"air" ,null, "", "", 0);
## Manualy Create an Unique Item that will represent a useful item in combat.
## It consist of a **texture**, a **name** and a **description**, which are `Texture2D`, `String` and `String` respectly
func _init(_item_id : StringName = &"air",
           _texture : Texture = null,
           _name : String = &"",
           _description : String = "",
           _max_quantity : int = 64,
           _flags : ItemType = ItemType.None,
           _attributes : Dictionary = {}) -> void:
    self.item_id = _item_id
    self.texture = _texture;
    self.name = _name;
    self.description = _description;
    self.max_quantity = _max_quantity;
    self.flags = _flags
    self.stackable = self.max_quantity > 1
    self.attributes = {}
