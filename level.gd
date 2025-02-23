extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Cursor.global_position = get_global_mouse_position()
