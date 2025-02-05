extends Node2D

var casse_vide = Global.casse_vide
var tableaux := []
var casse_selectionnee = [0, 0]
var pixel_haut_gauche = Vector2(0, 0)
var object_in = Global.player_inventaire
const object = preload("res://animated_sprite_2d.tscn")
var c := 0
var item_selectionne = null

func _ready() -> void:
	print(object_in)
	position = Vector2(45, 45)
	for i in range(5):
		tableaux.append([0, 0, 0, 0, 0])
	for i in range(5):
		for j in range(5):
			if object_in[c] == casse_vide:
				pass
			else:
				casse_selectionnee = [i, j]
				add_object(Vector2(i, j), c)
			c += 1

func add_object(casse, c):
	var pixel_postion = convertion_casse_2_pixel(casse)
	var object_i = object.instantiate()
	add_child(object_i)
	object_i.initialize(object_in[c][1],pixel_postion,object_in[c][0])
	#object_i.connect("input_event", Callable(self, "_on_item_input_event"))
	#print(pixel_postion, "Position de l'objet: ", object_i.global_position, object_in[c][0])

#func _on_item_input_event(viewport, event, shape_idx):
	#if event is InputEventMouseButton and event.pressed:
		#item_selectionne = event.target
		#print("Item sélectionné : ", item_selectionne)

func _input(event: InputEvent) -> void:
	if item_selectionne and event is InputEventMouseMotion:
		item_selectionne.global_position = get_global_mouse_position()
	elif event is InputEventMouseButton and not event.pressed:
		if item_selectionne:
			var nouvelle_casse = convertion_pixel_2_casse(item_selectionne.global_position)
			print("Nouvelle case : ", nouvelle_casse)
			item_selectionne = null

func convertion_casse_2_pixel(casse):
	var pixel = Vector2(45, 45)
	pixel.x += casse.x * 115
	pixel.x += casse.y * 100
	return pixel

func convertion_pixel_2_casse(coredone):
	var casse = Vector2(0, 0)
	coredone -= Vector2(45, 45)
	casse.x = int(coredone.x / 115)
	casse.y = int(coredone.y / 100)
	return casse
