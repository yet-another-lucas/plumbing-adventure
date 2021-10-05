extends Area2D

var player = null

func can_see_player():
	# true if player is in aggro range
	return player != null

func _on_AggroRange_body_entered(body):
	print("aggro range entered")
	player = body

func _on_AggroRange_body_exited(_body):
	print("aggro range exited")
	player = null


func _on_AggroRange_area_entered(area):
#	print("aggro range area entered")
	pass
