extends CharacterBody3D
signal projectile_fired
var can_attack = true
var in_attacks_area_entité := false

@export var speed = 2
@export var sprint_speed = 16
@export var normal_speed = 4

@export var speed_jump = 10
var can_jump = false :
	get():
		return is_on_floor()

@export var mouse_sensitivity := 0.003
var twist_input := 0.0
var pitch_input := 0.0

var inventair_instance = null
var inventair = preload("res://Scènes/map/Inventaire_Player.tscn")
var inventair_ouver = false

@onready var constructoin = $twistPivot/PichtPivot/plasse_constructoin
@onready var twist_pivot = $twistPivot
@onready var picht_pivot = $twistPivot/PichtPivot
@onready var timer = $Timer2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	construction_mov()
	if Input.is_action_pressed("sprint"):
		speed = sprint_speed
	else :
		speed = normal_speed
	#var input = Input.get_action_strength("ui_up")
	var input = Vector3.ZERO
	input.x = Input.get_axis("move_left","move-right")*speed
	input.z = Input.get_axis("move_forward","move_back")*speed
	if can_jump == true :
		velocity.y += Input.get_axis("e","jump")*speed_jump
	
	if not is_on_floor():
		velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta * 5
	
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
	
	if Input.is_action_just_pressed("attacks"):
		can_attack = true
		timer.start()
	else :
		Global.player_is_attacking = false
		
	if Input.is_action_just_pressed("e"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if inventair_ouver == false :
			inventair_instance = inventair.instantiate()
			add_child(inventair_instance)
			inventair_ouver = true
		else:
			remove_child(inventair_instance)
			inventair_instance.queue_free()
			inventair_instance = null
			inventair_ouver = false
	if Input.is_action_just_pressed("vue"):
		print(Global.player_inventaire)
		if $twistPivot/PichtPivot/Camera3D.position == Vector3(0,1.6,3):
			$twistPivot/PichtPivot/Camera3D.position = Vector3(0,0.6,0)
		else :
			$twistPivot/PichtPivot/Camera3D.position = Vector3(0,1.6,3)
		
	if Input.is_action_just_pressed("ui_down"):
		var main_object = Global.player_main_object
		if main_object <4:
			main_object +=1
		else:
			main_object -= 4
		$twistPivot/PichtPivot/Camera3D/Control/AnimatedSprite3D.frame = main_object
		Global.player_main_object = main_object
	if Input.is_action_just_pressed("tire"):
		emit_signal("projectile_fired")
	Global.player_potion = position
	move_and_slide()

func _on_timer_timeout():
	Global.player_is_attacking = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion :
		twist_input = - event.relative.x * mouse_sensitivity
		pitch_input = - event.relative.y * mouse_sensitivity

func damage(nb):
	Global.player_vie -= nb
	$twistPivot/PichtPivot/Camera3D/Control/ProgressBar.value = Global.player_vie
	if Global.player_vie < 0:
		queue_free()

func _on_demange_area_entered(area: Area3D) -> void:
	if area.collision_layer == 8 :
		damage(5)
	if area.collision_layer == 4:
		in_attacks_area_entité = true


func _on_demange_area_exited(area: Area3D) -> void:
	if area.collision_layer == 4:
		in_attacks_area_entité = false

func _on_timer_2_timeout() -> void:
	if can_attack == true :
		Global.player_is_attacking = true
		can_attack = false

func construction_mov() :
	if Input.is_action_just_pressed("molette_up"):
		constructoin.position.z += 1
	elif Input.is_action_just_pressed("molette_bas"):
		constructoin.position.z -= 1
