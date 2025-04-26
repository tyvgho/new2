extends DirectionalLight3D

@export var day = true
@export var tick : int = 2400
@export var days : int = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#rotation_degrees.x = tick % 360
	#days = tick / 360
	#tick += 1
	pass