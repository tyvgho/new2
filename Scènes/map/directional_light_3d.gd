extends DirectionalLight3D
var day = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	#if light_energy <5 and day:
		#print(light_energy,day,"1")
		#light_energy += 0.0001
	#elif (light_energy > 5 or not day) and light_energy > -5 :
		#day = false
		#print(light_energy,day,"2")
		#light_energy -= 0.0001
	#else:
		#print(light_energy,day,"3")
		#day = not day
