extends Area2D

const CutGrass = preload("res://Effects/BrushEffect.tscn")

func _on_Bush_body_entered(body):
	# Turn full growth off, reset, show and play the growing animation
	$Grown.visible = false
	$Growing.frame = 0
	$Growing.playing = true


func _on_Growing_animation_finished():
	# Swap out animation for static image
	$Grown.visible = true
	$Growing.playing = false


func _on_Hurtbox_area_entered(area):
	print('im cut')
	$Grown.visible = false
	$Growing.visible = true
	$Growing.frame = 0
	# need to instance a new Cut instead of swapping image
	var cutGrass = CutGrass.instance()
	get_parent().add_child(cutGrass)
	# set the position the grass effect to that of the grass
	cutGrass.global_position = global_position
	cutGrass.global_position.y += 11
	queue_free()
