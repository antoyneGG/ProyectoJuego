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
onready var player = get_tree().get_nodes_in_group("player")[0]

# Stats
const dmg = 10
var health = 40

enum{
	IDLE,
	PATROL,
	CHASE
}

func _ready():
	randomize()
	dir = DIRECTION[randi() % DIRECTION.size()]
	current_state = PATROL
	init_pos = global_position
	pass
	
func _physics_process(delta):
	var to = Vector2.ZERO
	
	match(current_state):
		IDLE:
			search_for_player()
		PATROL:
			to = patrol()
			search_for_player()
		CHASE:
			to = chase()
	
	if(continous % 100 == 0):
		dir = DIRECTION[randi() % DIRECTION.size()]
	vel.y += GRAV * delta
	vel = vel.move_toward(to, ACCEL * delta)
	vel = move_and_slide(vel, Vector2.UP)
	var collision = move_and_slide(knockbar_vector)
	knockbar_vector = lerp(knockbar_vector, Vector2.ZERO, 0.2)
	continous += 1

func chase():
	var player = decZ.player
	if player != null:
		var dir = (player.global_position - global_position).normalized()
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
	
func search_for_player():
	if decZ.player != null:
		current_state = CHASE

func take_damage(income_dmg):
	health -= income_dmg
	print("Me queda %d de vida" % health)
	knockbar_vector = (global_position - player.global_position) * knockbar_force
	if(health <= 0):
		dead()

func dead():
	queue_free()


func _on_Hurtbox_area_entered(area):
	if area.get_collision_layer() == 64:
		area.owner.take_damage(dmg)
