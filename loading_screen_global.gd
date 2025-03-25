extends Control

@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var loadingscreen : LoadingScreen = $LoadingScreen

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	LoadingScreen

func show():
	anim.play("showing")

func hide():
	anim.play("hiding")
