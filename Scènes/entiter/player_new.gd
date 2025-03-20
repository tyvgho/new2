class_name Player extends CharacterBody3D
signal projectile_fired
var can_attack := true
var can_move := true
var can_sprint := true
var is_sprinting := false
var can_open_inventory := true
var can_move_camera := true

@export_category("Stats")
var health = 100
@export var max_health = 100
var stamina = 100
@export var max_stamina = 100
@export var armor = 0
@export var speed = 4
@export var sprint_speed = 12
@export var normal_speed = 4
@export var speed_jump = 10

@export var mouse_sensitivity := 0.003
var twist_input := 0.0
var pitch_input := 0.0

var inventaire_ouvert = false

@export var default_camera_fov = 70
@export var sprint_camera_fov = 90
var current_camera_fov = default_camera_fov

@onready var constructoin = $twistPivot/PichtPivot/plasse_constructoin
@onready var twist_pivot = $twistPivot
@onready var picht_pivot = $twistPivot/PichtPivot
@onready var animation : AnimationPlayer = $twistPivot/PichtPivot/pereso_moche/AnimationPlayer
@export var Inventaire_I : PlayerInventory
@onready var timer = $Timer2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_sprint_process(delta)
	_inventaire_process(delta)
	
	var input = Vector3.ZERO
	input.x = Input.get_axis("move_left","move-right")*speed
	input.z = Input.get_axis("move_forward","move_back")*speed
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta * 5
	
	if input and can_move:
		animation.play("ArmatureAction_001",-1 ,4 if is_sprinting else 1.5)
	else:
		animation.stop(true)
	velocity = twist_pivot.basis * Vector3(input.x, velocity.y, input.z)
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$twistPivot.rotate_y(twist_input)
	$twistPivot/PichtPivot.rotate_x(pitch_input)
	$twistPivot/PichtPivot.rotation.x = clamp(
		$twistPivot/PichtPivot.rotation.x,
		-0.5,
		0.5
	)
	twist_input = 0.0
	pitch_input = 0.0	
		
	if Input.is_action_just_pressed("vue"):
		print(Global.player_inventaire)
		if $twistPivot/PichtPivot/Camera3D.position == Vector3(0,1.6,3):
			$twistPivot/PichtPivot/Camera3D.position = Vector3(0,0.6,0)
		else :
			$twistPivot/PichtPivot/Camera3D.position = Vector3(0,1.6,3)
		
	if Input.is_action_just_pressed("tire"):
		emit_signal("projectile_fired")
	Global.player_potion = position
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and can_move_camera:
		twist_input = - event.relative.x * mouse_sensitivity
		pitch_input = - event.relative.y * mouse_sensitivity

# func damage(nb):
# 	Global.player_vie -= nb
# 	$twistPivot/PichtPivot/Camera3D/Control/ProgressBar.value = Global.player_vie
# 	if Global.player_vie < 0:
# 		queue_free()

func construction_process(_delta : float) :
	if Input.is_action_just_pressed("molette_up"):
		constructoin.position.z += 1
	elif Input.is_action_just_pressed("molette_bas"):
		constructoin.position.z -= 1

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

func _inventaire_process(_delta : float):
	if Input.is_action_just_pressed("e") and can_open_inventory:
		if inventaire_ouvert:
			# Refermer l'inventaire
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			Inventaire_I.close_inventory()
		else:
			# Ouvrir l'inventaire
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			Inventaire_I.open_inventory()
		inventaire_ouvert = not inventaire_ouvert
