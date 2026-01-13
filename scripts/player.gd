extends CharacterBody2D


enum PlayerState{
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

@export var acceleration = 100
@export var deceleration = 100

const WALK_SPEED = 80.0
const DUCK_SPEED = 30.0
const RUN_SPEED = 130.0
const JUMP_VELOCITY = -250.0
var current_speed = WALK_SPEED
var direction = 0
var status: PlayerState
var jump_count = 0
@export var max_jump_count = 2

func move(speed: float, delta):	
	update_direction()
	if direction:
		velocity.x = move_toward(velocity.x, direction * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, deceleration * delta)
		
		
func _ready() -> void:
	go_to_idle_state()


func _physics_process(delta: float) -> void:
	print(jump_count)
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	match status:
		PlayerState.idle:
			idle_state(delta)
		PlayerState.walk:
			walk_state(delta)
		PlayerState.jump:
			jump_state(delta)
		PlayerState.duck:
			duck_state(delta)
		PlayerState.walk_duck:
			walk_duck_state(delta)
		PlayerState.fall:
			fall_state(delta)
	
	move_and_slide()

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
	

	
func idle_state(delta):
	current_speed = WALK_SPEED
	move(WALK_SPEED, delta)
	if velocity.x != 0:
		go_to_walk_state()
		return
	
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
		
	if Input.is_action_pressed("duck"):
		go_to_duck_state()
		return

func fall_state(delta):
	move(current_speed, delta)
	
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

func walk_state(delta):
	current_speed = WALK_SPEED
	move(WALK_SPEED, delta)
	
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
	
func jump_state(delta):
	move(current_speed, delta)
	if Input.is_action_just_pressed("jump") && can_jump():
		go_to_jump_state()
		return

	if velocity.y > 0:
		go_to_fall_state()
		return
		

func duck_state(delta):
	current_speed = DUCK_SPEED
	move(DUCK_SPEED, delta)
	
	if Input.is_action_just_released("duck"):
		exit_from_duck_state()
		go_to_idle_state()
		return 
		
	if direction !=0:
		go_to_walk_duck_state()
		return



func walk_duck_state(delta):
	current_speed = DUCK_SPEED
	move(DUCK_SPEED, delta)
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

func set_duck_collsion():
	colisao.shape.size.y = 11
	colisao.position.y = 2.5
	
func exit_from_duck_state():
	colisao.shape.size.y = 15
	colisao.position.y = 0.5



func update_direction():
	direction = Input.get_axis("left", "right")
	if direction < 0: 
		animacao.flip_h  = true
	elif direction > 0: 
		animacao.flip_h = false




#var walk_speed = 80.0
#var running_speed = 150.0
#const SLIDE_BONUS_DISTANCE = 35
#var sliding_speed
#var slide_cooldown = 0
#var JUMP_VELOCITY = -250.0
#var sliding = false
#var jumping = false
#var running = false
#
#func slide(ativo: bool, speed: float):
	#if ativo:
		#sliding = true
		#sliding_speed = speed + SLIDE_BONUS_DISTANCE
		#colisao.shape.size.y = 10
		#colisao.position.y = 2
	#else:
		#colisao.shape.size.y = 15
		#colisao.position.y = -0.5
		#sliding_speed = SLIDE_BONUS_DISTANCE
		#sliding = false









#func temp(delta: float) -> void:
	#if sliding:
		#sliding_speed = move_toward(sliding_speed, 0, 100 * delta)
		#slide_cooldown = move_toward(slide_cooldown, 5, 1 * delta)
		#
	#if !sliding:
		#slide_cooldown = move_toward(slide_cooldown, 0, 1 * delta)
	#
	#print(slide_cooldown)
	## Add the gravity.
	#if not is_on_floor():
		#velocity += get_gravity() * delta
	## Handle jump.
	#if Input.is_action_just_pressed("jump") and is_on_floor() and not sliding:
		#velocity.y = JUMP_VELOCITY
		#jumping = true
	#elif is_on_floor():
		#jumping = false
#
	#var direction := Input.get_axis("left", "right")
	#running = direction && Input.is_action_pressed("run")
	#
	## Get the input direction and handle the movement/deceleration.
	## As good practice, you should replace UI actions with custom gameplay actions.
	#var speed = sliding_speed if sliding else(running_speed if running else walk_speed)
	#if direction:
		#velocity.x = direction * speed
	#
	#else:
		#velocity.x = move_toward(velocity.x, 0, walk_speed)
	#
	##Comentario de teste
	#if sliding and is_on_floor():
		#if animacao.animation != "slide" and animacao.animation != "slide_loop":
			#animacao.play("slide")
		#elif animacao.animation == "slide" and animacao.frame == 2:
			#animacao.play("slide_loop")
#
	#elif not is_on_floor():
		#animacao.play("jump")
#
	#else:
		#if direction > 0:
			#animacao.flip_h = false
			#if running:
				#animacao.play("running")
			#else:
				#animacao.play("walk")
#
		#elif direction < 0:
			#animacao.flip_h = true
			#if running:
				#animacao.play("running")
			#else:
				#animacao.play("walk")
#
		#else:
			#animacao.play("idle")
	#
	#if (direction != 0) and Input.is_action_just_pressed("slide") and is_on_floor() and not jumping:
		#if slide_cooldown == 0:
			#if running:
				#slide(true, running_speed)
			#else:
				#slide(true, walk_speed)
	#elif direction == 0 or Input.is_action_just_released("slide") or jumping or sliding_speed == 0:
		#slide(false, 0)
	#
	#move_and_slide()
