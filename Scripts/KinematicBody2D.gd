extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var vel = Vector2.ZERO
const SPEED = 100
const ACC = 50
const FRICC = 15
const GRAV = 180
const JUMP = 200
var input_vector = Vector2.ZERO
var salto = 0

var current_state

var animatedSprite

var collHB

var coll

var posHB

enum{
	ATTACK,
	MOVE
}


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Listo")
	animatedSprite = $AnimatedSprite
	collHB = $Position2D/HitBox/CollisionShape2D
	posHB = $Position2D
	coll = $CollisionShape2D
	current_state = MOVE
	collHB.set_disabled(true)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	vel.y += GRAV * delta
	
	match(current_state):
		MOVE:
			var wl = Input.get_action_strength("Left")
			var wr = Input.get_action_strength("Right")
			input_vector.x = (wr - wl)
			
			if(input_vector != Vector2.ZERO):
				animatedSprite.play("moverse")
				var to = input_vector * SPEED
				vel = vel.move_toward(to, ACC * delta)
				if(input_vector.x == 1):
					scale.x = scale.y * 1
				elif(input_vector.x == -1):
					scale.x *= scale.y * -1
			else:
				animatedSprite.play("default")
				vel = vel.move_toward(Vector2.ZERO, FRICC * delta)
			
			if(Input.is_action_just_pressed("Jump") and is_on_floor()):
				vel.y -= JUMP
			if(Input.is_action_just_pressed("detener")):
				animatedSprite.stop()
			vel = move_and_slide(vel, Vector2.UP)
			if(Input.is_action_just_pressed("ataque")):
				current_state = ATTACK
		ATTACK:
			attacking()

func attacking():
	animatedSprite.play("pelea")

func _on_AnimatedSprite_frame_changed():
	print("muriendome")
	if(animatedSprite.get_animation() == "pelea"):
		if(animatedSprite.frame in [1, 2]):
			collHB.set_disabled(false)
		else:
			collHB.set_disabled(true)


func _on_AnimatedSprite_animation_finished():
	if(animatedSprite.get_animation() == "pelea"):
		animatedSprite.play("default")
		current_state = MOVE
