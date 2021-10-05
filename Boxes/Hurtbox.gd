extends Area2D

const HitEffect = preload("res://Effects/HitEffect.tscn")

var ward = false setget set_ward
onready var  timer = $Timer
onready var collisionShape = $CollisionShape2D

signal ward_started
signal ward_ended

func set_ward(value):
	ward = value #not usings self to set directly, to avoid recursion
	if ward == true:
		emit_signal("ward_started")
	else:
		emit_signal("ward_ended")

func start_ward(duration):
	set_ward(true)
	timer.start(duration)

func create_hit_effect(area):
	var effect = HitEffect.instance()
	get_tree().current_scene.add_child(effect)
	effect.global_position = global_position - Vector2(0, 8)
#	effect.global_position = global_position

func _on_Timer_timeout():
	set_ward(false)

# toggle the hurtbox after every hit
# to prevent bug where foe stays in the hurtbox and never triggers on_entered case
func _on_Hurtbox_ward_started():
	collisionShape.set_deferred("disabled", true)

func _on_Hurtbox_ward_ended():
	collisionShape.disabled = false
#	timer.stop() #can I use one_shot = true to avoid this? YES
