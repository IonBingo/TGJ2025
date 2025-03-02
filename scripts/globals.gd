extends Node

var scroll_offset: int = 0
var is_dragging: bool = false
var valid_wand: bool = true

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

var room_colors = [Color("e1a48b"), Color("bc2251"), Color("ff7c5d"), Color("513e5e"), Color("17133c"), Color("ffffff"), Color("ffffff")]

enum grab_states
{
	N,
	Y
}

var current_grab_state: grab_states = grab_states.N
