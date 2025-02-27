class_name UniqueItem extends Resource

@export var texture : Texture2D;
@export var name : String;
@export var description : String;

## Manualy Create an Unique Item that will represent a useful item in combat.
## It consist of a **texture**, a **name** and a **description**, which are `Texture2D`, `String` and `String` respectly
func _init(_texture : Texture, _name : StringName, _description : String) -> void:

    if not _texture:
        _texture = load("res://Godot/Assets/shroom_default.tres")
    if not _name:
        _name = "Default Shroom"
    if not _description:
        _description = "An normal mushroom with the texture of a golden one, gain 30 HP on use."

    self.texture = _texture;
    self.name = _name;
    self.description = _description;
