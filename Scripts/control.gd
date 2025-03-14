extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	set_process_input(false) # Désactive la gestion automatique des entrées
	mouse_filter = Control.MOUSE_FILTER_IGNORE # Ignore les entrées de la souris
