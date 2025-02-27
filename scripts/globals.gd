extends Node

var scroll_offset: int = 0
var is_dragging: bool = false

enum room_types
{
	NORMAL,
	KITCHEN,
	SUNROOM,
	VAMPIRE,
	SUMMONING,
	MIRROR,
	LIVING
}

enum grab_states
{
	N,
	Y
}

var current_grab_state: grab_states = grab_states.N
