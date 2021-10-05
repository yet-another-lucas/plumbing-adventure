extends KinematicBody2D

onready var stats = $Stats
onready var collisionShape = $CollisionShape2D
const THROW_SPEED = 12000
var shuriken_velocity = Vector2.ZERO
var thrown = false
var throw_vector = Vector2.ZERO

func _ready():
	# would be cool if they stuck in walls/trees/bushes
	# but they slide and move the player when thrown
	# need to figure this out
	collisionShape.disabled = true

func _physics_process(delta):
	if thrown:
		move_shuriken(delta)
	else:
		shuriken_velocity = Vector2.ZERO
		throw_vector = Vector2.ZERO

func throw(roll_vector, delta):
	throw_vector = roll_vector
	thrown = true

func move_shuriken(delta):
	shuriken_velocity = throw_vector * THROW_SPEED * delta
	shuriken_velocity = move_and_slide(shuriken_velocity)

func _on_Hitbox_area_entered(area):
	queue_free()
