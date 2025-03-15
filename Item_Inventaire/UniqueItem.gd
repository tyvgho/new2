class_name UniqueItem extends Resource

@export var texture : Texture2D;
@export var name : String;
@export var description : String;
@export var max_quantity : int;

static var empty_item = UniqueItem.new(null, "", "", 0);

## Manualy Create an Unique Item that will represent a useful item in combat.
## It consist of a **texture**, a **name** and a **description**, which are `Texture2D`, `String` and `String` respectly
func _init(_texture : Texture = null, _name : StringName = &"", _description : String = "", max_quantity : int = 64) -> void:
    self.texture = _texture;
    self.name = _name;
    self.description = _description;
    self.max_quantity = max_quantity
