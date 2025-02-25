extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Cursor.global_position = get_global_mouse_position()
	var all_valid = true
	for room in $Rooms.get_children():
		if room.locked_to_slot:
			room.check_valid()
		all_valid = all_valid and room.valid
	$Button.visible = all_valid
	
