extends Node3D

var current_tool = ""

# Dictionnaire des outils disponibles (chaque outil est un MeshInstance3D)
@onready var tools = {
	"pioche bois":$Cube_008,
	"pioche pierre":$Cube_011,
	"pioche fer":$Cube,
	"pioche mithril": $Cube_005,
	"epee bois": $Cube_006,
	"epee pierre": $Cube_009,
	"epee fer": $Cube_002,
	"epee mithril": $Cube_003,
	"hache bois": $Cube_007,
	"hache pierre": $Cube_010,
	"hache fer": $Cube_001,
	"hache mithril": $Cube_004
}


# Liste des outils pour changer d'arme avec "E"
var tool_types = ["pioche", "epee", "hache"]
var materials = ["bois", "pierre", "fer", "mithril"]
var current_tool_index = 0
var current_material_index = 0
func _ready() -> void:
	# Masquer tous les outils au début
	for tool_type in tools:
			tools[tool_type].visible = false

func show_tool(tool_key: String):
	# Vérifie si l'outil demandé existe
	if tool_key in tools:
		# Cacher l'outil précédent s'il existe
		if current_tool != "" and current_tool in tools:
			
			tools[current_tool].visible = false
		# Afficher le nouvel outil
		tools[tool_key].visible = true
		current_tool = tool_key

func _input(event):
	# Changer d'outil avec "E"
	if event.is_action_pressed("jump"):
		change_tool()

func change_tool():
	# Changer de type d'outil (pioche → épée → hache)
	current_tool_index = (current_tool_index + 1) % tool_types.size()
	var new_tool = tool_types[current_tool_index]

	# Changer de matériau (bois → pierre → fer → mithril)
	current_material_index = (current_material_index + 1) % materials.size()
	var new_material = materials[current_material_index]

	var new_tool_key = new_tool + " " + new_material
	show_tool(new_tool_key)
	print("Équipé :", new_tool_key)
