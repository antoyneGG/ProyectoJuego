extends KinematicBody2D


# Declare member variables here. Examples:
var vel = Vector2.ZERO
const SPEED = 200
const ACC = 190
const FRICC = 15
const GRAV = 250
const JUMP = 200
var input_vector = Vector2.ZERO
var salto = 0


# State machine
var current_state
enum{
	ATTACK,
	MOVE,
	INV,
	DEATH
}

# Animation
var animatedSprite

# Collition
var collHB
var coll
var posHB
var hitbox

# Stats
const meleeDMG = [10, 20, 30, 40, 50]
const expLevel = [5, 15, 30, 50, 80]
var actualExp = 0
var HP = 100
var level = 1


# Called when the node enters the scene tree for the first time.
func _ready():
	print("Listo")
	animatedSprite = $AnimatedSprite
	collHB = $Position2D/HitBox/CollisionShape2D
	posHB = $Position2D
	coll = $CollisionShape2D
	hitbox = $Position2D/HitBox
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
				if(not is_on_floor()):
					if(vel.y > 0):
						animatedSprite.play("caer")
					elif(vel.y < 0):
						animatedSprite.play("saltar")
					else:
						animatedSprite.play("saltarIdle")
				else:
					animatedSprite.play("moverse")
				var to = input_vector * SPEED
				vel = vel.move_toward(to, ACC * delta)
				if(input_vector.x == 1):
					animatedSprite.flip_h = false
					posHB.rotation_degrees = 0
				elif(input_vector.x == -1):
					animatedSprite.flip_h = true
					posHB.rotation_degrees = 180
			else:
				if(not is_on_floor()):
					if(vel.y > 0):
						animatedSprite.play("caer")
					elif(vel.y < 0):
						animatedSprite.play("saltar")
					else:
						animatedSprite.play("saltarIdle")
				else:
					animatedSprite.play("default")
				vel = vel.move_toward(Vector2.ZERO, 0)
				vel.x = 0
			
			if(Input.is_action_just_pressed("Jump") and is_on_floor()):
				vel.y -= JUMP
			if(Input.is_action_just_pressed("detener")):
				animatedSprite.stop()
			vel = move_and_slide(vel, Vector2.UP)
			if(Input.is_action_just_pressed("ataque")):
				current_state = ATTACK
		ATTACK:
			attacking()
		INV:
			invulnerability()
		DEATH:
			death()

func attacking():
	animatedSprite.play("pelea")

func _on_AnimatedSprite_frame_changed():
	if(animatedSprite.get_animation() == "pelea"):
		if(animatedSprite.frame in [1, 2]):
			collHB.set_disabled(false)
		else:
			collHB.set_disabled(true)

func _on_AnimatedSprite_animation_finished():
	if(animatedSprite.get_animation() == "pelea"):
		animatedSprite.play("default")
		current_state = MOVE
		

func _on_HitBox_area_entered(area):
	if area.get_collision_layer() == 256:
		area.owner.take_damage(meleeDMG[level - 1])
		
func invulnerability():
	hide()
	yield(get_tree().create_timer(0.2), "timeout")
	show()
	yield(get_tree().create_timer(0.2), "timeout")
	hide()
	yield(get_tree().create_timer(0.2), "timeout")
	show()
	current_state = MOVE

# Se debe que llamar esta funcion dentro de "hurtbox para recibir el daño
func take_damage(damage):
	HP -= damage
	print("Auchis me pego %d de danio y me dejo con %d de vida" % [damage, HP])
	if(HP <= 0):
		current_state = DEATH
	else:
		current_state = INV

func death():
	animatedSprite.play("morirse")
	if(animatedSprite.frame != 9):
		vel = vel.move_toward(Vector2.ZERO, 0)
		vel.x = 0
		get_tree().change_scene("res://Scenes/Game Over.tscn")
	else:
		hide()

func getExp(experience):
	actualExp += experience
	if(actualExp >= expLevel[level - 1]):
		level += 1
		actualExp = 0
		HP = 100
		print("Subiste al nivel %d" % level)
