class_name Player extends CharacterBody3D
signal projectile_fired
var can_attack := true
var can_move := true
var can_sprint := true
var is_sprinting := false
var can_open_inventory := true
var can_move_camera := true
var can_take_damang := true
var overrite_animation := false
var is_ejecter := false
var direction_ejecter = Vector3.ZERO
var a = 0

@export_category("Stats")
var health = 100
@export var max_health = 1000
var stamina = 100
@export var max_stamina = 100
@export var armor = 0
@export var speed = 4
@export var sprint_speed = 12
@export var normal_speed = 4
@export var speed_jump = 10
@export var player_Inventory : PlayerInventory
@export var player_Hotbar : Hotbar
@export var attack_damage = 1

@export_category("Other Settings")

@export var mouse_sensitivity := 0.003
var twist_input := 0.0
var pitch_input := 0.0

var inventaire_ouvert = false

@export var default_camera_fov = 70
@export var sprint_camera_fov = 90
var current_camera_fov = default_camera_fov

#@onready var constructoin = $twistPivot/PichtPivot/plasse_constructoin
@onready var skeleton 	 : Skeleton3D 		= $"twistPivot/pesonage-v1/Armature/Skeleton3D"
@onready var inventaire  : Control 			= $"twistPivot/pesonage-v1/Armature/Skeleton3D/BoneAttachment3D2/Camera3D/UI/Inventaire"
@onready var item_helder : ItemHelder     = $"twistPivot/pesonage-v1/Armature/Skeleton3D/BoneAttachment3D/ItemHelder"
@onready var hotbar 	 : Control 			= $"twistPivot/pesonage-v1/Armature/Skeleton3D/BoneAttachment3D2/Camera3D/UI/Hotbar"
@onready var twist_pivot : Node3D 		   	= $"twistPivot"
@onready var picht_pivot : Node3D 		   	= $"twistPivot/PichtPivot"
@onready var animation   : AnimationPlayer 	= $"twistPivot/pesonage-v1/AnimationPlayer"
@onready var shape_cast  : ShapeCast3D 	   	= $"twistPivot/PichtPivot/ShapeCast3D"
@onready var timer_a 	 : Timer 		   	= $"Timer"
@onready var timer 		 : Timer 		   	= $"Timer2"
var camera : Camera3D
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	camera = get_viewport().get_camera_3d()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	inventaire_ouvert = false
	player_Inventory.close_inventory()
	player_Inventory.visible = false

func change_player_handheld_item(item):
	Global.holded_item = item
	item_helder.current_tool = item

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_sprint_process(delta)
	_inventaire_process(delta)
	
	var input = Vector3.ZERO
	input.x = Input.get_axis("move_left","move_right")*speed
	input.z = Input.get_axis("move_forward","move_back")*speed
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta * 5
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += speed_jump

	if input and can_move and not overrite_animation :
		animation.play("cour" if is_sprinting else "marche" ,0.5 ,2)
	elif not overrite_animation:
		animation.play("imobile",0.5)
	velocity = twist_pivot.basis * Vector3(input.x, velocity.y, input.z)

	$twistPivot.rotate_y(twist_input)
	a += pitch_input
	a = clamp(a,-0.7,0.7)
	rotate_os(a,&"Os.003")
	twist_input = 0.0
	pitch_input = 0.0
	if Input.is_action_just_pressed("vue"):
		print(Global.player_inventaire)
		if camera.position == Vector3(0,1.6,3):
			camera.position = Vector3(0,0.6,0)
		else :
			camera.position = Vector3(0,1.6,3)
		
	if Input.is_action_just_pressed("tire"):
		if velocity == Vector3.ZERO:
			force_animation(&"frape")
		elif is_sprinting:
			force_animation(&"cours_frape")
		else :
			force_animation(&"marche_frape")
		attack()
		await animation.animation_finished
		emit_signal("projectile_fired")

	if Input.is_action_just_pressed("Tab (Inventaire)"):
		if Global.holded_item.item.name == "AK-47":
			overrite_animation = true
			get_tree().create_timer(1.5).timeout.connect(func(): overrite_animation = false)

	Global.player_potion = position
	if not is_ejecter:
		move_and_slide()
	else :
		ejection(direction_ejecter)

func ejection(direction):
	velocity =direction*20+Vector3(0,20,0)
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and can_move_camera:
		twist_input = - event.relative.x * mouse_sensitivity
		pitch_input = - event.relative.y * mouse_sensitivity

func damage(nb,ejection):

	if can_take_damang == true:
		direction_ejecter = ejection
		is_ejecter = true
		timer.start(0.1)
		timer_a.start(2)
		can_take_damang = false
		Global.player_vie -= nb
		$"twistPivot/pesonage-v1/Armature/Skeleton3D/BoneAttachment3D2/Camera3D/UI/HP".value = Global.player_vie
		if Global.player_vie <= 0:
			queue_free()


#func construction_process(_delta : float) :
	#if Input.is_action_just_pressed("molette_up"):
		#constructoin.position.z += 1
	#elif Input.is_action_just_pressed("molette_bas"):
		#constructoin.position.z -= 1

func _sprint_process(_delta : float):
	if Input.is_action_pressed("sprint") and can_sprint:
		speed = sprint_speed
		current_camera_fov = sprint_camera_fov
		is_sprinting = true
	else:
		speed = normal_speed
		current_camera_fov = default_camera_fov
		is_sprinting = false
	var cam = get_viewport().get_camera_3d()
	cam.fov = lerpf(cam.fov, current_camera_fov, _delta * 10)

func force_animation(animation_to_play : StringName):
	overrite_animation = true
	animation.play(animation_to_play)
	await animation.animation_finished
	overrite_animation = false

func _inventaire_process(_delta : float):
	if can_open_inventory and not inventaire_ouvert:
		if Input.is_action_just_pressed("molette_up"):
			player_Hotbar.select_previous_item()
		elif Input.is_action_just_pressed("molette_bas"):
			player_Hotbar.select_next_item()

	if Input.is_action_just_pressed("e") and can_open_inventory:
		print(inventaire,player_Inventory,Global.inventaire_player)
		if inventaire_ouvert:
			# Refermer l'inventaire
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			player_Inventory.close_inventory()
		else:
			# Ouvrir l'inventaire
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			player_Inventory.open_inventory()
		inventaire_ouvert = not inventaire_ouvert
func attack():
	can_attack = false  # Désactive temporairement l'attaque
	shape_cast.force_shapecast_update()  # Met à jour la détection
	if shape_cast.is_colliding():
		for i in range(shape_cast.get_collision_count()):
			var collider = shape_cast.get_collider(i)
			if collider.has_method("take_damage"):  # Vérifie si l'objet a une fonction pour prendre des dégâts
				collider.take_damage(attack_damage)

func rotate_os(rotations,os):
	var bone_id = skeleton.find_bone(os)  # Trouve l'ID de l'os
	if bone_id != -1:
		var rotation_offset = Quaternion.from_euler(Vector3(deg_to_rad(rotations)*-50, 0, 0))  # Rotation de 30° en Y
		skeleton.set_bone_pose_rotation(bone_id, rotation_offset)
	else:
		print("Os non trouvé :", os)


func _on_area_3d_body_entered(body: Node3D) -> void:
	print(body)
	var collider = body
	if collider.has_method("recuper_item"):  # Vérifie si l'objet a une fonction pour prendre des dégâts
		collider.recuper_item()


func invisibliliter() -> void:
	can_take_damang = true


func _on_timer_timeout() -> void:
	is_ejecter = false
