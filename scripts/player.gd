extends CharacterBody2D

@onready var animacao: AnimatedSprite2D = $AnimatedSprite2D
@onready var colisao: CollisionShape2D = $CollisionShape2D
@onready var crouch_logic: Node = $States/DuckAndSlideState
@onready var jump_and_fall_logic: Node = $States/JumpAndFallState
@onready var walk_and_run_logic: Node = $States/WalkAndRunState

enum PlayerState {
	idle,
	walk,
	jump,
	crouch,
	walk_crouch,
	fall,
	run,
	slide,
	dead,
}

const SPEEDS = {
	IDLE = 0.0,
	WALK = 60.0,
	CROUCH = 30.0,
	RUN = 110.0
}

@export var acceleration = 580
@export var deceleration = 580
@export var max_jump_count = 2

const JUMP_VELOCITY = -250.0
const SLIDE_SPEED_BONUS = 25
var current_speed = 0
var direction = 0
var status: PlayerState
var jump_count = 0

func move(speed: float, delta):
	if status != PlayerState.dead:
		update_direction()
		if direction:
			velocity.x = move_toward(velocity.x, direction * speed, (acceleration - speed) * delta)
		else:
			velocity.x = move_toward(velocity.x, 0, (deceleration - speed) * delta)
		
func _ready() -> void:
	go_to_idle_state()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	match status:
		PlayerState.idle:
			idle_state()
		PlayerState.walk, PlayerState.run:
			walk_and_run_logic.update(delta)
		PlayerState.jump, PlayerState.fall:
			jump_and_fall_logic.update(delta)
		PlayerState.crouch, PlayerState.walk_crouch, PlayerState.slide:
			crouch_logic.update(delta)
		PlayerState.dead:
			dead_state(delta)

	move(current_speed , delta)
	
	move_and_slide()

func go_to_dead_state():
	status = PlayerState.dead
	animacao.play("dead")
	velocity = Vector2.ZERO

func go_to_slide_state(distance_penalty):
	status = PlayerState.slide
	crouch_logic.sliding_distance = current_speed - distance_penalty
	current_speed = current_speed + SLIDE_SPEED_BONUS
	crouch_logic.sliding = true
	animacao.play("slide")
	set_crouch_collision()

func go_to_walk_crouch_state():
	current_speed = SPEEDS.CROUCH
	status = PlayerState.walk_crouch
	animacao.play("walk_crouching")
	set_crouch_collision()

func go_to_crouch_state():
	current_speed = SPEEDS.IDLE
	status = PlayerState.crouch
	animacao.play("crouch")
	set_crouch_collision()

func go_to_run_state():
	current_speed = SPEEDS.RUN
	status = PlayerState.run
	animacao.play("running")

func go_to_fall_state():
	status = PlayerState.fall
	animacao.play("fall")
	
func go_to_idle_state():
	current_speed = SPEEDS.IDLE
	status = PlayerState.idle
	animacao.play("idle")

func go_to_walk_state():
	current_speed = SPEEDS.WALK
	status = PlayerState.walk
	animacao.play("walk")
	
func go_to_jump_state():
	status = PlayerState.jump
	animacao.play("jump")
	velocity.y = JUMP_VELOCITY
	jump_count += 1
	
func can_slide():
	return crouch_logic.slide_cooldown == 0	



func idle_state():
	
	if direction != 0:
		go_to_walk_state()
		return
	
	if Input.is_action_just_pressed("jump"):
		go_to_jump_state()
		return
		
	if Input.is_action_pressed("crouch"):
		go_to_crouch_state()
		return

func dead_state(_delta):
	
	pass


func can_jump() -> bool:
	return jump_count < max_jump_count

func set_crouch_collision():
	colisao.shape.size.y = 11
	colisao.position.y = 2.5
	
func set_standing_collision():
	crouch_logic.sliding = false
	colisao.shape.size.y = 15
	colisao.position.y = 0.5

func update_direction():
	direction = Input.get_axis("left", "right")
	if direction < 0:
		animacao.flip_h = true
	elif direction > 0:
		animacao.flip_h = false


func _on_hitbox_area_entered(area: Area2D) -> void:
	if velocity.y > 0:
		#inimigo morre
		area.get_parent().take_damage()
		go_to_jump_state()
	else:
		#player morre
		go_to_dead_state()
