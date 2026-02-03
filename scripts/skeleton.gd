extends CharacterBody2D

@onready var bone_start_position: Node2D = $BoneStartPosition
@onready var animacao: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var wall_detector: RayCast2D = $WallDetector
@onready var ground_detector: RayCast2D = $GroundDetector
@onready var player_detector: RayCast2D = $PlayerDetector
const SPINNING_BONE = preload("uid://bvo814y066my0")


enum SkeletonState{
	walk,
	dead,
	attack,
}

const SPEED = 10.0
const JUMP_VELOCITY = -400.0

var status: SkeletonState

var direction = 1
var can_throw = true

func _ready() -> void:
	go_to_walk_state()


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	match status:
		SkeletonState.walk:
			walk_state(delta)	
		SkeletonState.dead:
			dead_state(delta)
		SkeletonState.attack:
			attack_state(delta)

	move_and_slide()

func go_to_attack_state():
	status = SkeletonState.attack
	animacao.play("attack")
	velocity = Vector2.ZERO
	can_throw = true
	
func attack_state(_delta):
	if animacao.frame == 2 && can_throw:
		throw_bone()
		can_throw = false
	pass


func go_to_dead_state():
	status = SkeletonState.dead
	animacao.play("dead")
	hitbox.process_mode = Node.PROCESS_MODE_DISABLED
	velocity = Vector2.ZERO
	
	
func go_to_walk_state():
	status = SkeletonState.walk
	animacao.play("walk")

func walk_state(_delta):
	velocity.x = SPEED * direction
	
	if wall_detector.is_colliding():
		direction *= -1
		scale.x *= -1
	
	if !ground_detector.is_colliding():
		direction *= -1
		scale.x *= -1
	
	if player_detector.is_colliding():
		go_to_attack_state()
		return
	

func dead_state(_delta):
	pass

func take_damage():
	go_to_dead_state()


func throw_bone():
	var new_bone = SPINNING_BONE.instantiate()
	add_sibling(new_bone)
	new_bone.position = bone_start_position.global_position
	new_bone.set_direction(direction)

func _on_animated_sprite_2d_animation_finished() -> void:
	if animacao.animation == "attack":
		go_to_walk_state()
		return
		
		
		
		
