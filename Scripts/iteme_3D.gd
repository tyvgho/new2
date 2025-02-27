extends CharacterBody3D
var item_type = ""
var loote
var quantiter = 0
var nb = 0
@onready var apparence = $modelle_arbre
func initialize(nouveau_nombre,new_position,new_type):
	print(new_type,"a",new_position,nouveau_nombre)
	self.item_type = new_type
	self.quantiter = nouveau_nombre
	self.position = new_position
	if item_type == "pierre":
		loote = {"name": "pierre", "count":quantiter}
		nb = 0
	elif item_type == "bois":
		loote = {"name": "bois", "count": 5}
		nb = 1
	elif item_type == "steak":
		loote = {"name":"steak","count":quantiter}
		nb = 2
	apparence.set_tree(nb)
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	move_and_slide()


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.collision_layer == 128 or area.collision_layer == 4:
		Global.player_inventaire_give(loote)
		queue_free()
