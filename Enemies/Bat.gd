extends KinematicBody2D

const BatDeathEffect = preload("res://Effects/BatDeathEffect.tscn")

export(int) var CHASE_ACCELERATION = 400
export(int) var WANDER_ACCELERATION = CHASE_ACCELERATION / 8
export(int) var CHASE_MAX_SPEED = 50
export(int) var WANDER_MAX_SPEED = 25
export(int) var FRICTION = 200
export(int) var WANDER_TARGET_BUFFER = 10
export var HIT_WARD_SECONDS = 0.4

enum {
	IDLE,
	WANDER,
	CHASE
}

onready var stats = $Stats
onready var aggroRange = $AggroRange
onready var sprite = $AnimatedSprite
onready var hurtbox = $Hurtbox
onready var softCollision = $SoftCollision
onready var wanderController = $WanderController
onready var blinkPlayer = $BlinkPlayer


var velocity = Vector2.ZERO
var knockback = Vector2.ZERO
var states = [IDLE, WANDER, WANDER] #prefer wander to idle

var state = WANDER

func _ready():
	pick_random_state()

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, 200 * delta)
	knockback = move_and_slide(knockback)
	match state:
		IDLE:
#			slow_down(delta)
			seek_player()
			wander_or_idle()
		WANDER:
			accelerate_toward(wanderController.target_position, delta)
			seek_player()
			wander_or_idle()
			decelerate_toward(wanderController.target_position)
		CHASE:
			chase_player(delta)
	# whether wandering or chasing
	move_bat(delta)
	

func move_bat(delta):
	if softCollision.is_colliding():
		velocity += softCollision.get_push_vector() * delta * 800
	velocity = move_and_slide(velocity)

func slow_down(delta):
	velocity = velocity.move_toward(Vector2.ZERO, 200 * delta)

func seek_player():
	if aggroRange.can_see_player():
		state = CHASE

func chase_player(delta):
	var player = aggroRange.player
	if player != null:
		accelerate_toward(player.global_position, delta)
	else:
		state = IDLE

func wander_or_idle():
	if wanderController.get_time_left() == 0:
		pick_random_state()
		wanderController.start_wander_timer(idle_timeout())

func pick_random_state():
	states.shuffle()
	state = states[0]

func accelerate_toward(position, delta):
	var direction = global_position.direction_to(position)
	match state:
		WANDER:
			velocity = velocity.move_toward(direction * WANDER_MAX_SPEED, WANDER_ACCELERATION * delta)
		CHASE:
			velocity = velocity.move_toward(direction * CHASE_MAX_SPEED, CHASE_ACCELERATION * delta)
	sprite.flip_h = velocity.x < 0

func decelerate_toward(position):
	if global_position.distance_to(position) <= WANDER_TARGET_BUFFER:
		pick_random_state()
		wanderController.start_wander_timer(idle_timeout())

func idle_timeout():
	return rand_range(0,2)

func _on_Hurtbox_area_entered(area):
	print("bat taking damage: ", area.damage)
	stats.health -= area.damage
	knockback = area.knockback_vector * 130
	hurtbox.create_hit_effect(self)
	hurtbox.start_ward(HIT_WARD_SECONDS)

func _on_Stats_no_health():
	queue_free()
	# reach into the Y sort
	var batDeathEffect = BatDeathEffect.instance()
	get_parent().add_child(batDeathEffect)
#	get_tree().current_scene.add_child(batDeathEffect)
	batDeathEffect.global_position = global_position


func _on_Hurtbox_ward_started():
	blinkPlayer.play("Start")


func _on_Hurtbox_ward_ended():
	blinkPlayer.play("Stop")
