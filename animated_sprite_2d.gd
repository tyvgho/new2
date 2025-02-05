extends AnimatedSprite2D
var touche_sourie = false
var recupere = false
var nombre = 1
var type = "aaaa"
@onready var animated_sprite = $"."
@onready var label = $Label
@onready var obeject_name = $Label2

func _ready() -> void:
	label.text = str(nombre)
	add_child(label)
	obeject_name.text = str(type)
	add_child(obeject_name)
func update_nombre(nombre):
	label.text = str(nombre)
	obeject_name.text = str(type)

func initialize(nombre, position,type):
	self.nombre = nombre
	self.position = position
	self.type = type
	label.text = str(nombre)
	obeject_name.text = str(type)

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("attacks") and touche_sourie:
		recupere = not(recupere)

func _physics_process(delta: float) -> void:
	if recupere == false:
		pass
	else :
		global_position = get_global_mouse_position()

func _on_area_2d_mouse_entered() -> void:
	touche_sourie = true


func _on_area_2d_mouse_exited() -> void:
	touche_sourie = false
