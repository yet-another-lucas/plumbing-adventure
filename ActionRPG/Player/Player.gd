extends KinematicBody2D

# TODOs
# merge grass effect scene into grass scene, just disable the hurt box after hitting once. start of video 11.
# grass effect getting triggered on walk is neat, have it trigger on run to make it animate
# what if grass has like 3-5hp and each run takes 1hp (sword takes 100), running around in battle will tramble the grass
# same idea, but for tall grass, leaving areas with reduced cover and/or mobility
# a collision mask/layer for each faction
# replace roll with log dodge

# animationplater. new animations need to be on loop
# so they can be manipuated in animationTree
# remember to turn off loop after mapppping the state

# when adding a texture to animated sprite, click on it after dropping it to open the menu

# part 13, bat hitbox " Couldn't you do distance_to() on the sword hitbox, make it normalized and negative, and use that for the knockback vector? "

# grass tutorial
# grass tutorial: https://www.youtube.com/watch?v=Twamv9Lnhxs
# grappling hook: https://www.youtube.com/watch?v=Wzrw6_KDMl4

# to get the grass, try copying a bush and replacing the sprite
# aim assist for kunai https://www.reddit.com/r/godot/comments/pb0mt2/aiming_with_a_controller_is_hard_so_i_added_aim/


# use export var to tweak vars in game
export var ACCELERATION = 500
export var MAX_SPEED = 80
export var MAX_CREEP_SPEED = 25
export var MAX_ROLL_SPEED = 125
export var FRICTION = 500
export var HIT_WARD_SECONDS = 2.5
export var ROLL_WARD_SECONDS = 0.5 #roll animation is 0.5 seconds

const PlayerHurtSound = preload("res://Player/PlayerHurtSound.tscn")
const Shuriken = preload("res://Player/Shuriken.tscn")

enum {
	MOVE,
	ROLL,
	ATTACK,
	THROW,
	HIDE,
	SNEAK
}
var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN #player starts facing down
var stats = PlayerStats
var targets = {}

onready var animationPlayer = $AnimationPlayer 
onready var animationTree = $AnimationTree 
onready var animationState = animationTree.get("parameters/playback")
onready var swordsHitBox = $Sword/Hitbox
onready var hurtbox = $Hurtbox
onready var blinkPlayer = $BlinkPlayer
onready var stealth = $Stealth
onready var stealthKb = $Stealth/StealthKB
onready var stealthShape = $Stealth/StealthKB/CollisionShape2D

func _ready():
	randomize()
	# stats has the signal, the signal self, the function self will call
	stats.connect("no_health", self, "queue_free")
	animationTree.active = true
	swordsHitBox.knockback_vector = roll_vector
	stealthShape.disabled = false

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
		ROLL:
			roll_state()
		ATTACK:
			attack_state(delta)
		THROW:
			throw_state(delta)
		SNEAK:
			sneak_state(delta)
	

#var player_move_input := Vector2.ZERO
#player_move_input.x = Input.get_action_strength("left_stick_right") - Input.get_action_strength("left_stick_left")
#player_move_input.x = Input.get_action_strength("left_stick_down") - Input.get_action_strength("left_stick_up")
#
#if Input.is_action_just
#
#if player_move_input.length() >= 0.85:
#    velocity_movement += player_move_input.normalized() * ACCELERATION
#    velocity_movement = velocity_movement.clamped(speed)
#elif player_move_input.length() > 0.015 and player_move_input.length() <= 0.85:
#    velocity_movement += player_move_input.normalized() * ACCELERATION
#    velocity_movement = velocity_movement.clamped(player_move_input.length() * speed)
#else:
#    velocity_movement = velocity_movement.move_toward(Vector2.ZERO, 100)
#velocity_movement = move_and_slide(velocity_movement)
#print(velocity_movement.length())

func move_state(delta):
	var input_vector = Vector2.ZERO
	var raw_input_vector = Vector2.ZERO
	raw_input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	raw_input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = raw_input_vector.normalized()
	# we are moving
	if raw_input_vector.length() >= 0.85: # I am the run-move state
		setup_move_and_animations(input_vector)
		velocity += input_vector.normalized() * ACCELERATION
		velocity = velocity.clamped(MAX_SPEED)
	elif raw_input_vector.length() > 0.015 and raw_input_vector.length() <= 0.85: # I am the sneak-move state
		setup_move_and_animations(input_vector)
		velocity += input_vector.normalized() * ACCELERATION
		velocity = velocity.clamped(input_vector.length() * MAX_CREEP_SPEED)
#		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else: # we are still
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	# time to boogie
	move()
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
		
	if Input.is_action_just_pressed("roll"):
		state = ROLL
		
	if Input.is_action_just_pressed("throw"):
		state = THROW

	if Input.is_action_just_pressed("sneak"):
		state = SNEAK

func attack_state(delta):
	velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	animationState.travel("Attack")
	
func attack_animation_finished():
	state = MOVE

func roll_animation_finished():
	velocity = velocity / 2 # slow stop
#	velocity = Vector2.ZERO # full stop
	state = MOVE

func roll_state():
	hurtbox.start_ward(ROLL_WARD_SECONDS)
	velocity = roll_vector * MAX_ROLL_SPEED
	animationState.travel("Roll")
	move()
	
func sneak_state(delta):
	#TODO: get roll and hide to work
	# get taking damage to break sneak
	# end roll in sneak state
	# get bats to not flatten the grass
	# get shurikens to not cut the grass
	stealthShape.disabled = true
	var input_vector = Vector2.ZERO
	var raw_input_vector = Vector2.ZERO
	raw_input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	raw_input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = raw_input_vector.normalized()
	# we are moving
	if input_vector != Vector2.ZERO: # I am the sneak-move state
		setup_sneak_and_animations(input_vector)
		velocity += input_vector.normalized() * ACCELERATION
		velocity = velocity.clamped(input_vector.length() * MAX_CREEP_SPEED)
#		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else: # we are still
		animationState.travel("Hidle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	# time to boogie
	move()
	
	if Input.is_action_just_pressed("attack"):
		stealthShape.disabled = false
		state = ATTACK
		
	if Input.is_action_just_pressed("roll"):
		state = ROLL
		
	if Input.is_action_just_pressed("throw"):
		state = THROW
	
	if Input.is_action_just_pressed("sneak"):
		stealthShape.disabled = false
		state = MOVE


func move():
	velocity = move_and_slide(velocity)

func _on_Hurtbox_area_entered(area):
	if hurtbox.ward == false:
		stats.health -= area.damage
		hurtbox.start_ward(HIT_WARD_SECONDS)
		hurtbox.create_hit_effect(self)
		get_tree().current_scene.add_child(PlayerHurtSound.instance())
		


func setup_move_and_animations(input_vector):
	roll_vector = input_vector
	swordsHitBox.knockback_vector = input_vector
	setup_animations(input_vector)
	animationState.travel("Run")
	
func setup_sneak_and_animations(input_vector):
	roll_vector = input_vector
	swordsHitBox.knockback_vector = input_vector
	setup_animations(input_vector)
	animationState.travel("Sneak")

func setup_animations(input_vector):
	animationTree.set("parameters/Idle/blend_position", input_vector)
	animationTree.set("parameters/Run/blend_position", input_vector)
	animationTree.set("parameters/Attack/blend_position", input_vector)
	animationTree.set("parameters/Roll/blend_position", input_vector)
	animationTree.set("parameters/Hidle/blend_position", input_vector)
	animationTree.set("parameters/Sneak/blend_position", input_vector)

func throw_state(delta):
	var shuriken = Shuriken.instance()
	get_parent().add_child(shuriken)
	shuriken.global_position = global_position
	if targets.size() > 0:
		var firstTarget = targets.keys()[0].get_parent()
		
		var enemyVector = Vector2.ZERO
		print("target acquired: ", firstTarget)
#		enemyVector = velocity.angle_to(firstTarget.global_position)
#		enemyVector = velocity.direction_to(firstTarget.global_position)
		enemyVector = global_position.direction_to(firstTarget.global_position)
		print("roll_vector: ", roll_vector)
		print("enemyVector: ", enemyVector)
		shuriken.throw(enemyVector, delta)
	else:
		shuriken.throw(roll_vector, delta)
	state = MOVE

func _on_Hurtbox_ward_started():
	if state != ROLL:
		blinkPlayer.play("Start")

func _on_Hurtbox_ward_ended():
	blinkPlayer.play("Stop")

func _on_Autoaim_area_entered(area):
#	print("someone entered autoaim")
	targets[area] = true

func _on_Autoaim_area_exited(area):
#	print("someone exited autoaim")
	targets.erase(area)
