extends AnimatedSprite2D
func  _ready() -> void:
	print(position)
func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		position = Vector2(513, 345)
