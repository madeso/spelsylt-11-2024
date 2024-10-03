extends KinematicBody2D

const ON_FLOOR_TIME = 0.1

const ACCELERATION = 800
const MAX_SPEED = 120
const FRICTION = 512

const GRAVITY = 1024
const JUMP_FORCE = 270
const JUMP_HOLD = 0.30

enum Anim {Unknown, Idle, Walk}

var old_anim = Anim.Unknown
var motion = Vector2.ZERO
var floor_timer = 0
var jump_buffer = 0

onready var sprite = $Sprite

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.playing = true
	pass # Replace with function body.


func _physics_process(delta):
	var x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var is_digging =  Input.get_action_strength("ui_select") > 0.5
	var is_jump = Input.is_action_just_pressed("ui_up")
	var is_jump_down = Input.get_action_strength("ui_up") > 0.5
	
	if is_on_floor():
		floor_timer = 0
		jump_buffer = 0
	else:
		floor_timer += delta
	
	var on_floor = floor_timer < ON_FLOOR_TIME
	
	if x_input != 0:
		var speed = ACCELERATION
		motion.x += x_input * speed * delta
		motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
		sprite.flip_h = x_input < 0
	else:
		var friction = FRICTION
		motion.x = sign(motion.x) * max(0, abs(motion.x) - friction * delta)
		
	motion.y += GRAVITY * delta
	if on_floor and is_jump:
		motion.y = -JUMP_FORCE
	if is_jump_down and jump_buffer < JUMP_HOLD:
		motion.y = -JUMP_FORCE
		jump_buffer += delta
	else:
		jump_buffer = JUMP_HOLD + 1
	
	motion = move_and_slide(motion, Vector2.UP)
	
	var anim = Anim.Idle
	if on_floor:
		if abs(motion.x) > 0:
			anim = Anim.Walk
		else:
			anim = Anim.Idle
	
	if anim != old_anim:
		old_anim = anim
		print("switching anim: ", anim)
		if anim == Anim.Idle:
			sprite.animation = "idle"
		elif anim == Anim.Walk:
			sprite.animation = "walk"
		else:
			print("unknown anim: ", anim)
