extends Area2D



onready var tallGrass = $TallGrass
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


# Player stepped on grass
func _on_Grass_body_entered(_body: RigidBody2D) -> void:
	print("entered grass")
	# Turn full growth off, reset, show and play the growing animation
	$Grown.visible = false
	$Growing.frame = 0
	$Growing.play("rise")
	$Growing.visible = true

# Growth animation finished
func _on_Growing_animation_finished() -> void:
	print("grass grew")
	# Swap out animation for static image
	$Grown.visible = true
	$Growing.visible = false



func _on_TallGrass_area_entered(area):
	print("entered grass")
	# Turn full growth off, reset, show and play the growing animation
	$Grown.visible = false
	$Growing.frame = 0
	$Growing.play("rise")
	$Growing.visible = true

