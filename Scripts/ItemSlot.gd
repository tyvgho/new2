@tool
class_name ItemSlot extends Control

@export var assign_item : InventoryItem :
	set(value):
		assign_item = (value as InventoryItem)
		item_name = (assign_item.item as UniqueItem).name
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
		if get_node(texture_np): # Evite les erreurs dans l'éditeur
			texture_rect.texture = item_texture 

@export var item_quantity : int :
	set(value):
		item_quantity = value
		if get_node(label_np) and label_quantity: # Evite les erreurs dans l'éditeur
			label_quantity.text = str(item_quantity)

@export_node_path("TextureRect") var texture_np : NodePath = ^"./TextureBorder/TextureRect"
@onready var texture_rect : TextureRect = get_node(texture_np)
@export_node_path("Label") var label_np : NodePath = ^"./Separator/Label"
@onready var label_quantity : Label = get_node(label_np)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
