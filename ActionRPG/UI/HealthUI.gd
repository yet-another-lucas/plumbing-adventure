extends Control

#TODO: why aren't the setters overriding this?
# why does hearts act like max hearts?

var hearts = 2 setget set_hearts
var max_hearts = 2 setget set_max_hearts
var heart_pixel_width = 15

onready var heartUIEmpty = $HeartUIEmpty
onready var heartUIFull = $HeartUIFull

func set_hearts(value):
	hearts = clamp(value, 0, max_hearts)
	if heartUIFull != null:
		heartUIFull.rect_size.x = hearts * heart_pixel_width
	
func set_max_hearts(value):
	max_hearts = max(value, 1)
	self.hearts = min(hearts, max_hearts)
	if heartUIEmpty != null:
		heartUIEmpty.rect_size.x = max_hearts * heart_pixel_width
	
func _ready():
	self.max_hearts = PlayerStats.maxim_health
	self.hearts = PlayerStats.health
	var _connect = PlayerStats.connect("health_changed", self, "set_hearts")
	_connect = PlayerStats.connect("max_health_changed", self, "set_max_hearts")
