extends Node2D

const GrassEffect = preload("res://Effects/GrassEffect.tscn")

func _on_Hurtbox_area_entered(_area):
	create_grass_effect()
	queue_free()
	
func create_grass_effect():
	# map the effect scene to the grass
	var grassEffect = GrassEffect.instance()
	# grass adds the effect to its own scene, bat adds it to the Ysort parent
#	get_tree().current_scene.add_child(grassEffect)
	get_parent().add_child(grassEffect)
	# set the position the grass effect to that of the grass
	grassEffect.global_position = global_position
