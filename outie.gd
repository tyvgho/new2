extends Node3D

var current_tool = {"type": "", "material": ""}

# Dictionnaire des outils disponibles (chaque outil est un MeshInstance3D)
@onready var tools = {
	"pickaxe": {
		"wood": $"Cube_008",
		"stone": $"Cube_011",
		"iron": $"Cube",
		"mithril": $"Cube_005"
	},
	"sword": {
		"wood": $"Cube_006",
		"stone": $"Cube_009",
		"iron": $"Cube_002",
		"mithril": $"Cube_003"
	},
	"axe": {
		"wood": $"Cube_007",
		"stone": $"Cube_010",
		"iron": $"Cube_001",
		"mithril": $"Cube_004"
	}
}

# Liste des outils pour changer d'arme avec "E"
var tool_types = ["pickaxe", "sword", "axe"]
var materials = ["wood", "stone", "iron", "mithril"]
var current_tool_index = 0
var current_material_index = 0
func _ready() -> void:
	# Masquer tous les outils au début
	for tool_type in tools:
		for material in tools[tool_type]:
			tools[tool_type][material].visible = false

func show_tool(tool_type: String, material: String):
	# Vérifie si l'outil demandé existe
	if tool_type in tools and material in tools[tool_type]:
		# Cacher l'outil précédent s'il existe
		if current_tool["type"] != "" and current_tool["material"] != "":
			tools[current_tool["type"]][current_tool["material"]].visible = false

		# Afficher le nouvel outil
		tools[tool_type][material].visible = true
		current_tool = {"type": tool_type, "material": material}

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

	show_tool(new_tool, new_material)
	print("Équipé :", new_tool, "en", new_material)
