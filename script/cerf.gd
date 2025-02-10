extends CharacterBody3D


const object = preload("res://scéne/entiter/itéme.tscn")

@onready var a = $AnimationPlayer
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var target_position = Vector3.ZERO
var moving = false
var mange = false
var in_attacks_area_player  = false
var vie = 10
var loote = ["steak",3]
@onready var timer = $Timer

func _physics_process(delta: float) -> void:
	# Ajouter la gravité
	if not is_on_floor():
		velocity.y -= 9.8 * delta  # Remplace `get_gravity()`
	
	# Se déplacer vers la cible
	if moving and not mange:
		a.play("marche")
		var direction = (target_position - position).normalized()
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

		# Vérifier si on est proche de la cible
		if Vector2(position.x, position.z).distance_to(Vector2(target_position.x, target_position.z)) < 0.5:
			randi_range(1,2)
			velocity = Vector3.ZERO
			moving = false
			if randi_range(1,2) == 1:
				mange= true
				# Jouer l'animation de broutage
				broutage()

	move_and_slide()

	# Déterminer une nouvelle destination
	if not moving:
		target_position = Vector3(
			randi_range(position.x - 10, position.x + 10),
			position.y,
			randi_range(position.z - 10, position.z + 10)
		)
		look_at(target_position, Vector3.UP)
		moving = true
		timer.start(10)

func _on_timer_timeout() -> void:
	moving = false  # Arrête le mouvement après le temps écoulé

func broutage() -> void:
	a.play("Actions réservées]")
	await a.animation_finished  # Attendre la fin de l'animation avant de passer à la suivante
	for i in range(randi_range(2,10)):
		a.play("Actions réservées]_001")
		await a.animation_finished  # Attendre la fin avant de reprendre le déplacement
	mange = false
	


func damang(nb_damang):
	vie -= nb_damang
	$Sprite3D/SubViewport/ProgressBar.value = vie  # Mettre à jour la barre de vie

	if vie <= 0:
		var object_i = object.instantiate()
		get_parent().add_child(object_i)  # Ajouter l'objet à la scène principale
		object_i.global_transform.origin = global_transform.origin  # Positionner correctement le steak
		object_i.initialize(loote[1], position, loote[0])  # Appeler la fonction d'initialisation

		print("Loot créé à :", object_i.global_transform.origin, "Type :", loote[0], "Quantité :", loote[1])

		queue_free()  # Supprimer le cerf

func _on_demange_area_entered(area: Area3D) -> void:
	#if moob_type == "cactus":
	if area.collision_layer == 8 :
		damang(2)
	if area.collision_layer == 4:
		in_attacks_area_player = true


func _on_demange_area_exited(area: Area3D) -> void:
	if area.collision_layer == 4:
		in_attacks_area_player == false
