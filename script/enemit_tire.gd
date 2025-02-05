extends CharacterBody3D
#tire
var is_attacking := false
var graviter = -5
var directiom = Vector3.ZERO
var speed = 5
var player_position = Global.player_potion
var player_proche = false
var vie = 10

func _physics_process(delta: float) -> void:
	player_position = Global.player_potion
	look_at(player_position, Vector3.UP)
	if player_proche == false:
		velocity = (player_position - global_transform.origin).normalized() * speed
		velocity.y += graviter
		move_and_slide()
	else :
		velocity = Vector3(0,-3,0)
		move_and_slide()
	if Input.is_action_just_pressed("ui_accept"):
		queue_free()


func attack():
	is_attacking = true


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.collision_layer == 2:
		player_proche = true

func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.collision_layer == 2:
		player_proche = false


func _on_demange_area_entered(area: Area3D) -> void:
	vie -=2
	if vie <0:
		queue_free()
