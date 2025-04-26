@tool
class_name ItemSlot extends TextureButton

var focused := false
var hovered := false
var holded := false

var IDI_Normal = preload("res://Item_Inventaire/Autre/IDI_Normal.tres")
var IDI_Hovered = preload("res://Item_Inventaire/Autre/IDI_Selectionnee.tres")
var IDI_Survole = preload("res://Item_Inventaire/Autre/IDI_Survole.tres")

@export var assign_item : ItemStack :
	set(value):
		assign_item = (value as ItemStack)
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
		if texture_rect: # Evite les erreurs dans l'éditeur
			texture_rect.texture = item_texture 

@export var item_quantity : int :
	set(value):
		item_quantity = value
		if label_quantity: # Evite les erreurs dans l'éditeur
			label_quantity.text = str(item_quantity)
			if item_quantity < 0:
				label_quantity.modulate = Color.CORAL
				label_quantity.visible = true
			else:
				label_quantity.modulate = Color.WHITE
			label_quantity.visible = (value < 0 and value > 1)

@export_node_path("TextureRect") var texture_np : NodePath = ^"./TextureBorder/TextureRect"
@onready var texture_rect : TextureRect = get_node_or_null(texture_np)
@export_node_path("Label") var label_np : NodePath = ^"./Separator/Label"
@onready var label_quantity : Label = get_node_or_null(label_np)
@export_node_path("Label") var progressbar_np : NodePath = ^"./TextureBorder/ProgressBar"
@onready var progressbar : ProgressBar = get_node_or_null(progressbar_np)

func _ready():
	update_item()

func _on_focus_entered() -> void:
	$Background.set("theme_override_styles/panel", IDI_Survole)

func _on_focus_exited() -> void:
	$Background.set("theme_override_styles/panel", IDI_Normal)

func _on_mouse_exited() -> void:
	if not $Background.has_focus():
		$Background.set("theme_override_styles/panel", IDI_Normal)

func _on_mouse_entered() -> void:
	if not $Background.has_focus():
		$Background.set("theme_override_styles/panel", IDI_Hovered)

func update_item():
	if assign_item != null:
		item_name = str((assign_item.item as UniqueItem).name)
		item_texture = (assign_item.item as UniqueItem).texture
		item_quantity = assign_item.quantity
		progressbar.visible = (assign_item.item as UniqueItem).attributes.has("durability")
		if progressbar.visible: 
			progressbar.min_value = 0
			progressbar.max_value = (assign_item.item as UniqueItem).attributes["max_durability"]
			progressbar.value = (assign_item.item as UniqueItem).attributes["durability"]

# Know if a button is pressed with a mouse, emit signal to parent with the index of the button
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			if get_parent() is InventoryGUI:
				(get_parent() as InventoryGUI).item_clicked.emit(assign_item, get_index(),event.button_index)
				update_item()
