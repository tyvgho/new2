extends Control

@onready var anim : AnimationPlayer = $AnimationPlayer
@onready var loadingscreen : LoadingScreen = $LoadingScreen

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func show_loading():
	anim.play("showing")
	move_to_front()

func hide_loading():
	anim.play_backwards("showing")
