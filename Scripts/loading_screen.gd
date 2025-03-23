class_name LoadingScreen extends Control

@export var loading_text : String = "Loading..."
@export var current : int = 0 : set = _on_current
@export var total : int = 0 : set = _on_total

func _on_current(value : int) -> void:
	current = value

func _on_total(value : int) -> void:
	total = value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if total != 0:
		$"VSplitContainer/ProgressBar".visible = true
		$"VSplitContainer/ProgressBar".value = float(current/total)*100.0
	else:
		$"VSplitContainer/ProgressBar".visible = false
	$"VSplitContainer/Label".text = loading_text + "..." + "(" + str(current) + "/" + str(total) + ")"
