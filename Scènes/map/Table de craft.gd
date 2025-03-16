class_name Interactible extends StaticBody3D

enum type_interactible {TABLE_DE_CRAFT, FOURNEAU}
@export_enum("Table de Craft", "Fourneau") var type : String

func apply_effect_at_all_object(node : Node, property : StringName, value : Variant) -> void:
	for child in node.get_children():
		child.set(property, value)


func _ready() -> void:
	apply_effect_at_all_object($workbench ,"transparency", 1)
	for i in range(100, 1, -1):
		apply_effect_at_all_object($workbench ,"transparency", float(i/100.0))
		await get_tree().create_timer(0.01).timeout
	apply_effect_at_all_object($workbench ,"transparency", 0)