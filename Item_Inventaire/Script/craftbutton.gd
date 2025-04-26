extends Control

@onready var progress : ProgressBar = $ProgressBar
@onready var button : Button = $"Button"
var is_crafting : bool = false
var craft_progression : float = 0
var craft_boost : float = 1
@export var craft : Recipe
@export var connected_inventory : Array[ItemStack]
#@export var pz : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	button.button_down.connect(_on_button_down)
	button.button_up.connect(_on_button_up)

func _on_button_down():
	progress.show()
	
func _on_button_up():
	progress.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$"TextureRect".texture = craft.result.item.texture
	$"Button".text = craft.result.item.name

	if craft.is_valid() and craft.has_all_items(connected_inventory):
		button.disabled = false
	else:
		button.disabled = true
