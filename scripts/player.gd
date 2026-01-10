extends CharacterBody2D
@onready var colisao: CollisionShape2D = $CollisionShape2D


enum PlayerState{
	idle,
	walk, 
	jump,
	run,
	slide,	
}


@onready var animacao: AnimatedSprite2D = $AnimatedSprite2D

const SPEED = 80.0
const JUMP_VELOCITY = -250.0

var status: PlayerState

func _ready() -> void:
	go_to_idle_state()


func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	match status:
		PlayerState.idle:
			idle_state()
		PlayerState.walk:
			walk_state()
		PlayerState.jump:
			jump_state()
	
	move_and_slide()
	
	
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
	
	
func idle_state():
	move()
	if velocity.x != 0:
		go_to_walk_state()
		return
	
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return

func walk_state():
	move()
	if velocity.x == 0:
		go_to_idle_state()
		return
		
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
	
func jump_state():
	move()
	if is_on_floor():
		if velocity.x == 0:
			go_to_idle_state()
		else:
			go_to_walk_state()
		return
	

func move():
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
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
