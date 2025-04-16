extends CharacterBody3D
@export_enum("wendigo","cactus") var moob_type : String
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

signal projectile_fired
@onready var timer = $Timer
@onready var animation = $AnimationPlayer

func  _ready() -> void:
	$Sprite3D/SubViewport/ProgressBar.max_value = vie
	if moob_type == "wendigo":
		print("a")
		good_distance = 1
	if moob_type == "cactus":
		print("b")
		good_distance = 5

func _physics_process(delta: float) -> void:
	player_position = Global.player_potion
	player_distance = int(sqrt((player_position.x-position.x)**2+(player_position.z-position.z)**2))
	look_at(player_position, Vector3.UP)
	if player_distance > good_distance:
		velocity = (player_position - global_transform.origin).normalized() * speed
		velocity.y += graviter
		move_and_slide()
		if moob_type == "cactus":
			animation.play("rampe_001")
	else :
		if moob_type =="cactus" and can_attacking == true:
			can_attacking = false
			animation.play("Actions réservées]")
			await animation.animation_finished
			emit_signal("projectile_fired")
			timer.start(3)
			animation.play("Actions réservées]_001")


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
