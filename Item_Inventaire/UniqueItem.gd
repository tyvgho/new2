class_name UniqueItem extends Resource



@export var texture : Texture2D;
@export var name : String;
@export var description : String;
@export var stackable : bool = false
@export var max_quantity : int;
@export var item_id : StringName;
@export_flags("None","Building","Consumable","Tool","Weapon","Armor") var flags : int = 0
@export var attributes : Dictionary = {};

static var empty_item = UniqueItem.new("air" ,null, "", "", 0);

## Manualy Create an Unique Item that will represent a useful item in combat.
## It consist of a **texture**, a **name** and a **description**, which are `Texture2D`, `String` and `String` respectly
func _init(_item_id : StringName, _texture : Texture = null, _name : StringName = &"", _description : String = "", max_quantity : int = 64) -> void:
    self.item_id = _item_id
    self.texture = _texture;
    self.name = _name;
    self.description = _description;
    self.max_quantity = max_quantity
