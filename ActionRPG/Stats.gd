extends Node
# le stats service
# project settings > autoload

export var maxim_health = 1 setget set_maxim_health
var health = maxim_health setget set_health

signal no_health
signal health_changed(value)
signal max_health_changed(value)

func set_maxim_health(value):
	maxim_health = value
	self.health = min(health, maxim_health)
	emit_signal("max_health_changed", maxim_health)

func set_health(value):
	health = value
	emit_signal("health_changed", health)
	if health <= 0:
		emit_signal("no_health")

func _ready():
	self.health = maxim_health
