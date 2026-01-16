extends CharacterBody2D


enum PlayerState {
	idle,
	walk,
	jump,
	duck,
	walk_duck,
	fall,
	run,
	slide,
}

@onready var animacao: AnimatedSprite2D = $AnimatedSprite2D
@onready var colisao: CollisionShape2D = $CollisionShape2D

@export var acceleration = 580
@export var deceleration = 580

const WALK_SPEED = 60.0
const DUCK_SPEED = 30.0
const RUN_SPEED = 110.0
const JUMP_VELOCITY = -250.0
const SLIDE_COOLDOWN_FACTOR = 3
const SLIDE_BONUS_DISTANCE = 35
var slide_cooldown = 0
var slide_speed_bonus = 0
var sliding_speed = current_speed
var sliding: bool
var current_speed = WALK_SPEED
var direction = 0
var status: PlayerState
var jump_count = 0

@export var max_jump_count = 2

func move(speed: float, delta):
	update_direction()
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, (acceleration - speed) * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, (deceleration - speed) * delta)
		
func _ready() -> void:
	go_to_idle_state()


func _physics_process(delta: float) -> void:
	if sliding:
		sliding_speed = move_toward(sliding_speed , 0, 100 * delta)
		slide_cooldown = move_toward(slide_cooldown, 5, SLIDE_COOLDOWN_FACTOR * delta)
	if !sliding:
		slide_cooldown = move_toward(slide_cooldown, 0, 1 * delta)
	
	print(slide_cooldown)


	if not is_on_floor():
		velocity += get_gravity() * delta
	match status:
		PlayerState.idle:
			idle_state()
		PlayerState.walk:
			walk_state()
		PlayerState.jump:
			jump_state()
		PlayerState.duck:
			duck_state()
		PlayerState.walk_duck:
			walk_duck_state()
		PlayerState.fall:
			fall_state()
		PlayerState.run:
			run_state()
		PlayerState.slide:
			slide_state()
	
	move(current_speed , delta)
	
	move_and_slide()

func go_to_slide_state():
	status = PlayerState.slide
	sliding_speed = current_speed - slide_speed_bonus
	current_speed = current_speed + 25
	sliding = true
	animacao.play("slide")
	set_duck_collsion()



func go_to_run_state():
	status = PlayerState.run
	animacao.play("running")

func go_to_fall_state():
	status = PlayerState.fall
	animacao.play("fall")
	
func go_to_walk_duck_state():
	status = PlayerState.walk_duck
	animacao.play("walk_ducking")
	set_duck_collsion()

	
func go_to_idle_state():
	status = PlayerState.idle
	animacao.play("idle")

func go_to_walk_state():
	status = PlayerState.walk
	animacao.play("walk")
	
	
func go_to_jump_state():
	status = PlayerState.jump
	animacao.play("jump")
	velocity.y = JUMP_VELOCITY
	jump_count += 1

func go_to_duck_state():
	status = PlayerState.duck
	animacao.play("duck")
	set_duck_collsion()
	
func can_slide():
	return slide_cooldown == 0	

func slide_state():

	if sliding_speed <= 0 or Input.is_action_just_released("slide"):
		exit_from_duck_state()
		if direction != 0:
			if Input.is_action_pressed("run"):
				go_to_run_state()
			else:
				go_to_walk_state()
		else:
			go_to_idle_state()
		return
		
	if Input.is_action_just_pressed("jump"):
		exit_from_duck_state()
		go_to_jump_state()
		return
		
func run_state():
	current_speed = RUN_SPEED

	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
	
	if Input.is_action_just_released("run"):
		go_to_walk_state()
		return	
	
	if velocity.x == 0:
		go_to_idle_state()
		return

	if Input.is_action_pressed("duck"):
		go_to_walk_duck_state()
		return
	
	if !is_on_floor():
		jump_count += 1
		go_to_fall_state()
		return

	if Input.is_action_just_pressed("slide") && can_slide():
		slide_speed_bonus = 45
		go_to_slide_state()
		return


func idle_state():
	current_speed = WALK_SPEED
	if velocity.x != 0:
		go_to_walk_state()
		return
	
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
		
	if Input.is_action_pressed("duck"):
		go_to_duck_state()
		return

func fall_state():
	
	if Input.is_action_just_pressed("jump") && can_jump():
		go_to_jump_state()
		return
	
	if is_on_floor():
		jump_count = 0
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()
		return

func can_jump() -> bool:
	return jump_count < max_jump_count

func walk_state():
	current_speed = WALK_SPEED
	
	if velocity.x == 0:
		go_to_idle_state()
		return
		
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
		
	if Input.is_action_pressed("duck"):
		go_to_walk_duck_state()
		return
		
	if !is_on_floor():
		jump_count += 1
		go_to_fall_state()
		return

	if Input.is_action_pressed("run"):
		go_to_run_state()
		return
		
	if Input.is_action_just_pressed("slide") && can_slide():
		slide_speed_bonus = 10
		go_to_slide_state()
		return
	
func jump_state():
	if Input.is_action_just_pressed("jump") && can_jump():
		go_to_jump_state()
		return

	if velocity.y > 0:
		go_to_fall_state()
		return
		

func duck_state():
	current_speed = DUCK_SPEED
	
	if Input.is_action_just_released("duck"):
		exit_from_duck_state()
		go_to_idle_state()
		return
		
	if direction != 0:
		go_to_walk_duck_state()
		return

	

func walk_duck_state():
	current_speed = DUCK_SPEED
	if Input.is_action_just_released("duck"):
		exit_from_duck_state()
		go_to_walk_state()
		return
		
	if direction == 0:
		go_to_duck_state()
		return
	
	if Input.is_action_just_pressed("jump"):
		exit_from_duck_state()
		current_speed = WALK_SPEED
		go_to_jump_state()
		return

	if !is_on_floor():
		jump_count += 1
		go_to_fall_state()
		return
	


func set_duck_collsion():
	colisao.shape.size.y = 11
	colisao.position.y = 2.5
	
func exit_from_duck_state():
	sliding = false
	colisao.shape.size.y = 15
	colisao.position.y = 0.5


func update_direction():
	direction = Input.get_axis("left", "right")
	if direction < 0:
		animacao.flip_h = true
	elif direction > 0:
		animacao.flip_h = false
