extends CharacterBody2D
@onready var animacao: AnimatedSprite2D = $AnimatedSprite2D
@onready var colisao: CollisionShape2D = $CollisionShape2D

var walk_speed = 80.0
var running_speed = 150.0
const SLIDE_SPEED = 35
var sliding_speed
var JUMP_VELOCITY = -250.0
var sliding = false
var jumping = false
var running = false

func slide(ativo: bool, speed: float):
	if ativo:
		sliding = true
		sliding_speed = speed + SLIDE_SPEED
		colisao.shape.size.y = 10
		colisao.position.y = 2
	else:
		colisao.shape.size.y = 16
		colisao.position.y = -1
		sliding_speed = SLIDE_SPEED
		sliding = false

func _physics_process(delta: float) -> void:
	if sliding:
		sliding_speed = move_toward(sliding_speed, 0, 100 * delta)
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	print(position.y)
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and not sliding:
		velocity.y = JUMP_VELOCITY
		jumping = true
	elif is_on_floor():
		jumping = false

	var direction := Input.get_axis("left", "right")
	running = direction && Input.is_action_pressed("run")
	
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var speed = sliding_speed if sliding else(running_speed if running else walk_speed)
	if direction:
		velocity.x = direction * speed
	
	else:
		velocity.x = move_toward(velocity.x, 0, walk_speed)
	
	#Comentario de teste
	if sliding and is_on_floor():
		if animacao.animation != "slide" and animacao.animation != "slide_loop":
			animacao.play("slide")
		elif animacao.animation == "slide" and animacao.frame == 2:
			animacao.play("slide_loop")

	elif not is_on_floor():
		animacao.play("jump")

	else:
		if direction > 0:
			animacao.flip_h = false
			if running:
				animacao.play("running")
			else:
				animacao.play("walk")

		elif direction < 0:
			animacao.flip_h = true
			if running:
				animacao.play("running")
			else:
				animacao.play("walk")

		else:
			animacao.play("idle")
	
	if (direction != 0) and Input.is_action_just_pressed("slide") and is_on_floor() and not jumping:
		if running:
			slide(true, running_speed)
		else:
			slide(true, walk_speed)
	elif direction == 0 or Input.is_action_just_released("slide"):
		slide(false, 0)
	if jumping:
		slide(false, 0)
	
	move_and_slide()
