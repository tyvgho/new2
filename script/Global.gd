extends Node
var player_potion = Vector3.ZERO
var player_vie = 20
var player_is_attacking := false
var casse_vide = ["", 0]
var player_aute_bar := [["",0],["",0],["",0],["",0],["",0]]
var player_main_object := 0
var player_inventaire = []
var stack = 64


func _ready() -> void:
	for i in range(30): 
		player_inventaire.append(["", 0])

func player_invetér_give(loote):
		print(loote,len(player_inventaire))
		var give_place = 0
		var found = false
		for i in range(player_inventaire.size()):
			if player_inventaire[i][0] == loote[0] and player_inventaire[i][1] < stack:
				print(player_inventaire[i][1],loote[1])
				player_inventaire[i][1] += loote[1]
				print(player_inventaire[i][1],loote[1])
				found = true
				break
			elif player_inventaire[i] == casse_vide:
				give_place = i
				player_inventaire[give_place] = loote.duplicate()
				break
		if not found:
			player_inventaire[give_place] = loote.duplicate()
