extends StaticBody2D

var occupied = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Globals.is_dragging:
		$Sprite2D.modulate = Color.GREEN_YELLOW
	else:
		$Sprite2D.modulate = Color.DIM_GRAY
