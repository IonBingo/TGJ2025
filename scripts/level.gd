extends Node2D

@export var next_level: String

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Globals.valid_wand:
		$Cursor/Sprite2D.frame = 0
	else: 
		$Cursor/Sprite2D.frame = 1
	$Cursor.global_position = get_global_mouse_position()
	var all_valid = true
	var scroll_delta = 0
	if Globals.current_grab_state == Globals.grab_states.N:
		if Input.is_action_just_pressed("scrup"):
			scroll_delta = 20
			Globals.scroll_offset += 20
			Globals.scroll_offset = clamp(Globals.scroll_offset, -500, 0)
		elif Input.is_action_just_pressed("scrdn"):
			scroll_delta = -20
			Globals.scroll_offset -= 20
			Globals.scroll_offset = clamp(Globals.scroll_offset, -500, 0) 
	for room in $Rooms.get_children():
		if room.locked_to_slot or room.fixed_room:
			room.check_valid()
		elif not room.fixed_room:
			room.global_position.y += scroll_delta
			room.global_position.y = clamp(room.global_position.y, room.start_pos.y - 500, room.start_pos.y)
		all_valid = all_valid and room.valid
	$Button.visible = all_valid
	


func _on_button_button_down():
	get_tree().change_scene_to_file(next_level)
