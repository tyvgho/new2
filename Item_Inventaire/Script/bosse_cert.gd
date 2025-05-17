extends CharacterBody3D

@onready var shape_cast = $cerf2/Armature_002/ShapeCast3D
# === CONFIGURATION ===
@export var vitesse: float = 10.0
@export var distance_att_lourde: float = 9.0
@export var distance_att_moyenne: float = 10.0
var vie = 50
var position_joueur = Global.player_potion
var attack_damage = 5
# === TIMERS ===
var temps_attente: float = 1
var delai_prochaine_action: float = 0.0

# === ÉTAT ===
enum EtatBoss { ATTENTE, DEPLACEMENT, ATTAQUE, CHARGE_EN_COURS }
var etat_actuel: EtatBoss = EtatBoss.ATTENTE

# === ANIMATION ===
@onready var anim = $cerf2/AnimationPlayer

var anim_charge
var distance_charge = 0.0
var direction_charge = Vector3.ZERO

# === READY ===
func _ready() -> void:
	etat_actuel = EtatBoss.DEPLACEMENT

# === PHYSIQUE ===
func _physics_process(delta):
	
	position_joueur = Global.player_potion
	if etat_actuel != EtatBoss.CHARGE_EN_COURS:
		look_at(position_joueur, Vector3.UP)
	delai_prochaine_action -= delta
	var distance = global_position.distance_to(position_joueur)
	if delai_prochaine_action <= 0 and is_on_floor() and etat_actuel != EtatBoss.CHARGE_EN_COURS:
		match etat_actuel:
			EtatBoss.ATTENTE:
				if distance <= distance_att_lourde:
					attaquer("attcke_lourde")
				elif distance <= distance_att_moyenne:
					preparer_charge("attack_dache", distance)
					anim_charge="attack_dache"
				else:
					preparer_charge("charge", distance)
					anim_charge="charge"

			EtatBoss.DEPLACEMENT:
				deplacer_vers_joueur(delta)
				if distance <= distance_att_moyenne:
					changer_etat(EtatBoss.ATTENTE)

			EtatBoss.ATTAQUE:
				changer_etat(EtatBoss.DEPLACEMENT)

	elif etat_actuel == EtatBoss.CHARGE_EN_COURS:
		deplacement_charge(delta,anim_charge)

	elif etat_actuel == EtatBoss.DEPLACEMENT:
		deplacer_vers_joueur(delta)
	elif not is_on_floor():
		velocity.y -=9
		move_and_slide()
# === ATTAQUE ===
func attaquer(nom_anim):
	changer_etat(EtatBoss.ATTAQUE)
	anim.play(nom_anim)
	delai_prochaine_action = anim.current_animation_length + randf_range(0.5, 1.0)
	frape()

# === DEPLACEMENT NORMAL ===
func deplacer_vers_joueur(_delta):
	anim.play("cours")
	var direction = (position_joueur - global_position).normalized()
	velocity = direction * vitesse
	if not is_on_floor():
		velocity.y -= 9
	move_and_slide()

# === CHANGEMENT D'ÉTAT ===
func changer_etat(nouvel_etat: EtatBoss):
	print("Nouvel état :", nouvel_etat)
	etat_actuel = nouvel_etat
	match nouvel_etat:
		EtatBoss.ATTENTE:
			print("a")
			anim.play("imobile")
			delai_prochaine_action = temps_attente + randf_range(0.5, 1.0)
		EtatBoss.DEPLACEMENT:
			print("b")
			anim.play("cours")
			delai_prochaine_action = randf_range(1.5, 3.0)
		EtatBoss.ATTAQUE:
			print("c")
			pass
		EtatBoss.CHARGE_EN_COURS:
			print("d")
			pass  # anim déjà lancé dans preparer_charge()

# === PRÉPARER UNE CHARGE / ATTAQUE À DISTANCE ===
func preparer_charge(nom_anim, distance_joueur):
	anim.play(nom_anim)
	direction_charge = (position_joueur - global_position).normalized()
	distance_charge = distance_joueur + 3.0
	delai_prochaine_action = anim.current_animation_length
	changer_etat(EtatBoss.CHARGE_EN_COURS)

# === MOUVEMENT DE CHARGE ===
func deplacement_charge(delta,nom_anim):
	frape()
	if vitesse < 20:
		vitesse +=1
	anim.play(nom_anim)
	var mouvement = direction_charge * vitesse
	var deplacement = mouvement * delta
	if deplacement.length() > distance_charge:
		deplacement = direction_charge * distance_charge
	velocity = deplacement / delta
	if not is_on_floor():
		velocity.y -= 9
	move_and_slide()
	distance_charge -= deplacement.length()
	print(direction_charge)
	if distance_charge < 0.1:
		vitesse = 10
		changer_etat(EtatBoss.ATTENTE)
func frape():
	direction_charge = (position_joueur - global_position).normalized()
	if shape_cast.is_colliding():
		for i in range(shape_cast.get_collision_count()):
			var collider = shape_cast.get_collider(i)
			if self != collider and Global.player_vie>0:
				if collider.has_method("damage"):  # Vérifie si l'objet a une fonction pour prendre des dégâts
					collider.damage(attack_damage,direction_charge)
func take_damage(nb_damang):
	$Sprite3D/SubViewport/ProgressBar.value = vie
	vie -= nb_damang
	velocity = Vector3(0,-3,0)
	move_and_slide()
	print(vie)
	if vie < 0:
		queue_free()
