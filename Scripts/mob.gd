extends CharacterBody3D
@export_enum("wendigo","cactus","requin") var moob_type : String
@export var spike_damage = 2
var can_attacking := true
var is_attacking := false
var graviter = -5
var directiom = Vector3.ZERO
var speed = 5
var player_position = Global.player_potion
var player_proche = false
var vie = 10
var in_attacks_area_player = false
var player_distance = Vector3.ZERO
var good_distance = 0
var last_direction

signal projectile_fired
@onready var timer = $Timer
@onready var animation = $AnimationPlayer
var shapecast : ShapeCast3D = null

func  _ready() -> void:
	$Sprite3D/SubViewport/ProgressBar.max_value = vie
	if moob_type == "wendigo" or moob_type == "requin":
		shapecast = $ShapeCast3D
		print(shapecast)
		good_distance = 1
	if moob_type == "cactus":
		good_distance = 5

func _physics_process(_delta: float) -> void:
	player_position = Global.player_potion
	player_distance = int(sqrt((player_position.x-position.x)**2+(player_position.z-position.z)**2))
	print(player_distance)
	look_at(player_position, Vector3.UP)
	if player_distance > good_distance:
		velocity = (player_position - global_transform.origin).normalized() * speed
		velocity.y += graviter
		move_and_slide()
		if moob_type == "cactus":
			animation.play("rampe_001")
		elif moob_type == "requin":
			animation.play("nage")
		elif moob_type == "wendigo":
			animation.play("marche")
		last_direction = velocity.normalized()
	else :
		
		if moob_type =="cactus" and can_attacking == true:
			can_attacking = false
			animation.play("Actions réservées]")
			await animation.animation_finished
			emit_signal("projectile_fired")
			timer.start(3)
			animation.play("Actions réservées]_001")
		elif moob_type == "requin":
			animation.play("mord")
		elif moob_type == "wendigo":
			animation.play("frape")
			frape()


		velocity = Vector3(0,-3,0)
		move_and_slide()

func take_damage(nb_damang):
	$Sprite3D/SubViewport/ProgressBar.value = vie
	vie -= nb_damang
	velocity = Vector3(0,-3,0)
	move_and_slide()
	if vie < 0:
		queue_free()
func attack():
	is_attacking = true
func frape():
	if shapecast:
		if shapecast.is_colliding():
			for i in range(shapecast.get_collision_count()):
				
				var collider = shapecast.get_collider(i)
				if self != collider and Global.player_vie>0:
					if collider.has_method("damage"):  # Vérifie si l'objet a une fonction pour prendre des dégâts
						collider.damage(spike_damage,last_direction)