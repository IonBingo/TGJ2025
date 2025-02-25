extends Node2D

@export var room_type: Globals.room_types
var valid = false
var draggable = false
var in_slot = false
var locked_to_slot = false
var overlapping = false
var target_slot
var occupied_slot
var offset: Vector2
var start_pos: Vector2

func check_valid():
	match room_type:
			Globals.room_types.NORMAL:
				valid = true
			Globals.room_types.KITCHEN:
				valid = true
			Globals.room_types.SUNROOM:
				var areas = $Anchor/Edges.get_overlapping_areas()
				for area in areas:
					if area.is_in_group('OOB'):
						valid = true
						$Anchor/RoomTiles.modulate = Color.YELLOW
						return
				valid = false
				$Anchor/RoomTiles.modulate = Color.LIGHT_GOLDENROD
			Globals.room_types.VAMPIRE:
				var areas = $Anchor/Edges.get_overlapping_areas()
				for area in areas:
					if area.is_in_group('OOB'):
						valid = false
						$Anchor/RoomTiles.modulate = Color.MEDIUM_PURPLE
						return
				valid = true
				$Anchor/RoomTiles.modulate = Color.PURPLE
			Globals.room_types.SUMMONING:
				var areas = $Anchor/Edges.get_overlapping_areas()
				for area in areas:
					var neighbor = area.get_parent().get_parent()
					if "room_type" in neighbor and neighbor.room_type == Globals.room_types.KITCHEN:
						valid = false
						$Anchor/RoomTiles.modulate = Color.YELLOW_GREEN
						return
				valid = true
				$Anchor/RoomTiles.modulate = Color.WEB_GREEN
				
func _ready():
	start_pos = global_position
	match room_type:
			Globals.room_types.KITCHEN:
				$Anchor/RoomTiles.modulate = Color.DARK_GOLDENROD
			Globals.room_types.SUNROOM:
				$Anchor/RoomTiles.modulate = Color.LIGHT_GOLDENROD
			Globals.room_types.VAMPIRE:
				$Anchor/RoomTiles.modulate = Color.MEDIUM_PURPLE
			Globals.room_types.SUMMONING:
				$Anchor/RoomTiles.modulate = Color.YELLOW_GREEN
			


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	if draggable:
		if Input.is_action_just_pressed("click_l"):
			if locked_to_slot:
				valid = false
				locked_to_slot = false
				occupied_slot.occupied = false
			offset = get_global_mouse_position() - global_position
			Globals.is_dragging = true
		if Input.is_action_pressed("click_l"):
			if Input.is_action_just_pressed("click_r"):
				$Anchor.rotation_degrees += 90
			var temp = get_global_mouse_position() - offset
			global_position = Vector2(snapped(temp.x,16), snapped(temp.y,16))
		elif Input.is_action_just_released("click_l"):
			Globals.is_dragging = false
			if in_slot and not target_slot.occupied and not overlapping:
				target_slot.occupied = true
				position = Vector2(target_slot.position.x - 8, target_slot.position.y - 8)
				draggable = false
				in_slot = false
				locked_to_slot = true
				occupied_slot = target_slot
			else:
				draggable = false
				global_position = start_pos

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


func _on_room_shape_mouse_exited():
	if not Globals.is_dragging:
		draggable = false


func _on_room_shape_area_entered(area):
	overlapping = true


func _on_room_shape_area_exited(area):
	if $Anchor/RoomShape.get_overlapping_areas().size() == 0:
		overlapping = false
