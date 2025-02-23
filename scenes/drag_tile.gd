extends Node2D

var draggable = false
var in_slot = false
var locked_to_slot = false
var target_slot
var occupied_slot
var offset: Vector2
var start_pos: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	$Anchor/Sprite2D.modulate = Color.CADET_BLUE

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if draggable:
		if Input.is_action_just_pressed("click_r"):
			$Anchor.rotation_degrees += 90
		if Input.is_action_just_pressed("click_l"):
			if locked_to_slot:
				locked_to_slot = false
				occupied_slot.occupied = false
			if not start_pos:
				start_pos = global_position
			offset = get_global_mouse_position() - global_position
			Globals.is_dragging = true
		if Input.is_action_pressed("click_l"):
			var temp = get_global_mouse_position() - offset
			global_position = Vector2(snapped(temp.x,16), snapped(temp.y,16))
		elif Input.is_action_just_released("click_l"):
			Globals.is_dragging = false
			if in_slot and not target_slot.occupied:
				$Anchor/Sprite2D.modulate = Color.WHITE
				print(target_slot.global_position)
				target_slot.occupied = true
				position = Vector2(target_slot.position.x - 8, target_slot.position.y - 8)
				draggable = false
				in_slot = false
				locked_to_slot = true
				occupied_slot = target_slot
			else:
				$Anchor/Sprite2D.modulate = Color.CADET_BLUE
				draggable = false
				global_position = start_pos

func _on_area_2d_mouse_entered():
	pass
	#if not Globals.is_dragging:
	#	draggable = true
	#	$Anchor/Sprite2D.modulate = Color.WEB_GRAY
	
func _on_area_2d_mouse_exited():
	pass
	#if not Globals.is_dragging:
	#	draggable = false
	#	$Anchor/Sprite2D.modulate = Color.WHITE

func _on_area_2d_body_entered(body):
	if body.is_in_group('slots'):
		if not body.occupied:
			in_slot = true
			target_slot = body

func _on_area_2d_body_exited(body):
	if body.is_in_group('slots'):
		in_slot = false


func _on_room_shape_mouse_entered():
	if not Globals.is_dragging:
		draggable = true
		$Anchor/Sprite2D.modulate = Color.WEB_GRAY


func _on_room_shape_mouse_exited():
	if not Globals.is_dragging:
		draggable = false
		$Anchor/Sprite2D.modulate = Color.WHITE
