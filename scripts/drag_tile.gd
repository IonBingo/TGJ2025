extends Node2D

# Type of room
@export var room_type: Globals.room_types
# Room valid status
var valid = false
# Can room be dragged?
var draggable = false
# Is room over a slot?
var in_slot = false
# Is the room locked in?
var locked_to_slot = false
# Is the room overlapping with another or the edge?
var overlapping = false
# Slot the room wants to go into
var target_slot
# Slot that the room is in
var occupied_slot
# Offset for following the mouse
var offset: Vector2
# Original location of piece in inventory
var start_pos: Vector2
# Keeps track of when piece was originally a living room
var is_living: bool = false

signal invalid_wand
signal valid_wand

# Gets the size of a room in number of cells
func get_room_size() -> int:
	return $Anchor/RoomTiles.get_used_cells(0).size()
	
# Updates the valid status of the room
func update_status(new_valid: bool) -> void:
	valid = new_valid

# Checks the valid status of the room and updates it
func check_valid() -> void:
	if is_living:
		var largest_neighbor
		var largest_size = 0
		var areas = $Anchor/Edges.get_overlapping_areas()
		for area in areas:
			var neighbor = area.get_parent().get_parent()
			if neighbor.has_method("get_room_size"):
				var size = neighbor.get_room_size()
				if size > largest_size:
					largest_size = size
					largest_neighbor = neighbor
		if largest_neighbor:
			room_type = largest_neighbor.room_type
		else:
			room_type = Globals.room_types.LIVING
			update_status(false)
					
	match room_type:
		Globals.room_types.NORMAL:
			update_status(true)
		Globals.room_types.KITCHEN:
			update_status(true)
		Globals.room_types.SUNROOM:
			var areas = $Anchor/Edges.get_overlapping_areas()
			for area in areas:
				if area.is_in_group('OOB'):
					update_status(true)
					return
			update_status(false)
		Globals.room_types.VAMPIRE:
			var areas = $Anchor/Edges.get_overlapping_areas()
			for area in areas:
				if area.is_in_group('OOB'):
					update_status(false)
					return
			update_status(true)
		Globals.room_types.SUMMONING:
			var areas = $Anchor/Edges.get_overlapping_areas()
			for area in areas:
				var neighbor = area.get_parent().get_parent()
				if "room_type" in neighbor and neighbor.room_type == Globals.room_types.KITCHEN:
					update_status(false)
					return
			update_status(true)

# Rotates the room by erasing and redrawing the cells
func rotate_room() -> void:
	# Rotate areas
	$Anchor/Edges.rotation_degrees -= 90
	$Anchor/RoomShape.rotation_degrees -= 90
	$Anchor/SelectionPoint.rotation_degrees -= 90
	
	# Get current room's cells
	var used_cells = $Anchor/RoomTiles.get_used_cells(0)
	if used_cells.is_empty():
		return

	# Compute rotated cells
	var rotated_cells = []
	for cell in used_cells:
		rotated_cells.append(Vector2i(cell.y, -cell.x)) # 90-degree clockwise rotation
		
	# Get terrain set and type from root tile
	var tile_data = $Anchor/RoomTiles.get_cell_tile_data(0, used_cells[0])
	if not tile_data:
		return

	# Erase all tiles
	for cell in used_cells:
		$Anchor/RoomTiles.erase_cell(0, cell)
	
	# Draw tiles in new cells
	$Anchor/RoomTiles.set_cells_terrain_connect(0, rotated_cells, tile_data.get_terrain_set(), tile_data.get_terrain(), true)

# Sets up starting position and tracks if the room began as a living room
func _ready():
	is_living = room_type == Globals.room_types.LIVING
	start_pos = global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):	
	if draggable:
		$Anchor/RoomTiles.position.y = -10
		z_index = 1
		if Globals.current_grab_state == Globals.grab_states.Y:
			if not in_slot or target_slot.occupied or overlapping:
				Globals.valid_wand = false
			else:
				Globals.valid_wand = true
		if Input.is_action_just_pressed("click_l"):
			if Globals.current_grab_state == Globals.grab_states.N:			
				if locked_to_slot:
					update_status(false)
					locked_to_slot = false
					occupied_slot.occupied = false
				offset = get_global_mouse_position() - global_position
				Globals.is_dragging = true
				Globals.current_grab_state = Globals.grab_states.Y
			elif Globals.current_grab_state == Globals.grab_states.Y:
				Globals.is_dragging = false
				if in_slot and not target_slot.occupied and not overlapping:
					target_slot.occupied = true
					position = Vector2(target_slot.position.x - 8, target_slot.position.y - 8)
					draggable = false
					in_slot = false
					locked_to_slot = true
					occupied_slot = target_slot
				else:
					if is_living:
						room_type = Globals.room_types.LIVING
					update_status(false)
					draggable = false
					var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_SPRING)
					tween.tween_property(self, "global_position", Vector2(start_pos.x, start_pos.y + Globals.scroll_offset), 0.2)
				Globals.current_grab_state = Globals.grab_states.N
		if Globals.current_grab_state == Globals.grab_states.Y: 
			if not locked_to_slot and Input.is_action_just_pressed("click_r"):
				rotate_room()
			var temp = get_global_mouse_position() - offset
			global_position = Vector2(snapped(temp.x,16), snapped(temp.y,16))
	else:
		$Anchor/RoomTiles.position.y = -8
		z_index = 0

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

func _on_room_shape_area_entered(_area):
	overlapping = true

func _on_room_shape_area_exited(_area):
	if $Anchor/RoomShape.get_overlapping_areas().size() == 0:
		overlapping = false
