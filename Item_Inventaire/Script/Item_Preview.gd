class_name Item_Preview extends Sprite2D

@export var item : InventoryItem

@onready var texture_rect : TextureRect = $TextureBorder/TextureRect
@onready var label : Label = $Separator/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
