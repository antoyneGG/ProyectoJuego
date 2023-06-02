extends KinematicBody2D

const ACCEL = 100
const MAX_SPEED = 200
const DIRECTION = [-1, 1]
const GRAV = 180
var vel = Vector2.ZERO
var continous = 0
var current_state = 0
var dir = 0
var init_pos
var knockbar_vector = Vector2.ZERO
var knockbar_force = 10
onready var decZ = $DetectionZone
onready var hurtbox = $Hurtbox
onready var animatedSprite = $AnimatedSprite
onready var posHB = $Position2D/HitBox
onready var collHB = $Position2D/HitBox/CollisionShape2D
onready var playerK = get_tree().get_nodes_in_group("player")[0]

# Stats
const dmg = 15
const attackDmg = 20
const experience = 15
var health = 80

enum{
	IDLE,
	PATROL,
	CHASE,
	DEATH,
	ATTACK
}

func _ready():
	randomize()
	dir = DIRECTION[randi() % DIRECTION.size()]
	current_state = PATROL
	init_pos = global_position
	collHB.set_disabled(true)
	pass
	
func _physics_process(delta):
	var to = Vector2.ZERO
	
	match(current_state):
		IDLE:
			search_for_player()
			animatedSprite.play("default")
		PATROL:
			to = patrol()
			search_for_player()
			animatedSprite.play("moving")
			if(continous % 100 == 0):
				dir = DIRECTION[randi() % DIRECTION.size()]
		CHASE:
			to = chase()
			animatedSprite.play("moving")
		ATTACK:
			attacking()
		DEATH:
			death()
	
	vel.y += GRAV * delta
	vel = vel.move_toward(to, ACCEL * delta)
	vel = move_and_slide(vel, Vector2.UP)
	var collision = move_and_slide(knockbar_vector)
	knockbar_vector = lerp(knockbar_vector, Vector2.ZERO, 0.2)
	if(vel.x < 0):
		animatedSprite.flip_h = true
		posHB.rotation_degrees = 180
	elif(vel.x > 0):
		animatedSprite.flip_h = false
		posHB.rotation_degrees = 0
	continous += 1

func chase():
	var player = decZ.player
	if player != null:
		var dis = player.global_position - global_position
		var dir = (player.global_position - global_position).normalized()
		if(dis.x < 35):
			current_state = ATTACK
		return Vector2(dir.x * MAX_SPEED, 0)
	else:
		current_state = PATROL
		return Vector2.ZERO

func patrol():
	if(is_on_wall() or check_bounds()):
		dir *= -1
		init_pos = global_position
	return Vector2(dir * MAX_SPEED, 0)  
	
func check_bounds():
	var l_bound = global_position.x < (init_pos.x - 50)
	var r_bound = global_position.x > (init_pos.x + 50)
	#print(r_bound or l_bound) 
	return l_bound or r_bound
	
func attacking():
	animatedSprite.play("attack")

func _on_AnimatedSprite_frame_changed():
	if(animatedSprite.get_animation() == "attack"):
		if(animatedSprite.frame in [10]):
			collHB.set_disabled(false)
		else:
			collHB.set_disabled(true)

func _on_AnimatedSprite_animation_finished():
	if(animatedSprite.get_animation() == "attack"):
		animatedSprite.play("moving")
		current_state = CHASE

func search_for_player():
	if decZ.player != null:
		current_state = CHASE

func take_damage(income_dmg):
	health -= income_dmg
	print("Me queda %d de vida" % health)
	knockbar_vector = (global_position - playerK.global_position) * knockbar_force
	if(health <= 0):
		current_state = DEATH

func death():
	animatedSprite.play("morir")
	if(animatedSprite.frame != 22):
		vel = vel.move_toward(Vector2.ZERO, 0)
		vel.x = 0
	else:
		playerK.getExp(experience)
		queue_free()


func _on_Hurtbox_area_entered(area):
	if area.get_collision_layer() == 64:
		area.owner.take_damage(dmg)


func _on_HitBox_area_entered(area):
	if area.get_collision_layer() == 64:
		area.owner.take_damage(attackDmg)
