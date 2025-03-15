@tool
class_name ItemSlot extends TextureButton

var focused := false
var hovered := false
var holded := false

@export var assign_item : InventoryItem :
	set(value):
		assign_item = (value as InventoryItem)
		if value != null:
			item_name = str((assign_item.item as UniqueItem).name)
			item_texture = (assign_item.item as UniqueItem).texture
			item_quantity = assign_item.quantity

@export var item_name : String : # Variable item_name créee par l'inspecteur
	set(value):
		item_name = value
		if self: # Si le node "actuel" existe alors on modifie la propriété "Tooltip Text"
			self.tooltip_text = item_name # Tooltip s'affiche quand la souris est sur l'objet / permet d'éviter les erreur

@export var item_texture : Texture2D:
	set(value):
		item_texture = value
		if get_node_or_null(texture_np): # Evite les erreurs dans l'éditeur
			texture_rect.texture = item_texture 

@export var item_quantity : int :
	set(value):
		item_quantity = value
		if get_node_or_null(label_np) and label_quantity: # Evite les erreurs dans l'éditeur
			label_quantity.text = str(item_quantity)
			label_quantity.visible = (value > 1)

@export_node_path("TextureRect") var texture_np : NodePath = ^"./TextureBorder/TextureRect"
@onready var texture_rect : TextureRect = get_node_or_null(texture_np)
@export_node_path("Label") var label_np : NodePath = ^"./Separator/Label"
@onready var label_quantity : Label = get_node_or_null(label_np)

func _ready():
	if assign_item != null:
		item_name = (assign_item.item as UniqueItem).name
		item_texture = (assign_item.item as UniqueItem).texture
		item_quantity = assign_item.quantity





func _on_focus_entered() -> void:
	print("Focus Entered")
func _on_focus_exited() -> void:
	print("Focus Exited")


func _on_mouse_exited() -> void:
	print("Mouse Exited")
func _on_mouse_entered() -> void:
	print("Mouse Entered")

func _on_button_down() -> void:
	print("Button Down")


