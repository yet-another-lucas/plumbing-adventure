extends Camera2D

onready var topLeft = $Limits/TopLeft
onready var bottomLeft = $Limits/BottomRight

func _ready():
	limit_top = topLeft.position.y
	limit_left = topLeft.position.x
	limit_bottom = bottomLeft.position.y
	limit_right = bottomLeft.position.x
