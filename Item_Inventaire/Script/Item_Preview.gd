@tool
class_name Item_Preview extends Sprite2D

@export var item : ItemStack : set = _set_item

@onready var texture_rect : TextureRect = $TextureBorder/TextureRect
@onready var label : Label = $Separator/Label


func _set_item(value):
	item = value

	if item == null:
		if texture_rect: texture_rect.texture = null

		if label: label.text = ""
	else:
		if texture_rect: # Evite les erreurs dans l'éditeur
				texture_rect.texture = item.item.texture

		if label: # Evite les erreurs dans l'éditeur
				label.text = str(item.quantity)
				label.visible = (item.quantity > 1)

func _process(delta):
	if not Engine.is_editor_hint():
		global_position = get_global_mouse_position()
