extends Node

@onready var player: CharacterBody2D = owner
var slide_cooldown = 0
var sliding_distance = 0
var sliding: bool = false

const SLIDE_COOLDOWN_FACTOR = 3

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if sliding:
		sliding_distance = move_toward(sliding_distance , 0, 100 * delta)
		slide_cooldown = move_toward(slide_cooldown, 5, SLIDE_COOLDOWN_FACTOR * delta)
	else:
		slide_cooldown = move_toward(slide_cooldown, 0, 1 * delta)
		
	print(slide_cooldown)
	
func update(_delta):
	match player.status:
		player.PlayerState.crouch:
			crouch_state()

		player.PlayerState.walk_crouch:
			walk_crouch_state()

		player.PlayerState.slide:
			slide_state()

func walk_crouch_state():
	if Input.is_action_just_released("crouch"):
		player.exit_crouch_state()
		player.go_to_walk_state()
		return
		
	if player.direction == 0:
		player.go_to_crouch_state()
		return
	
	if Input.is_action_just_pressed("jump"):
		player.exit_crouch_state()
		player.current_speed = player.SPEEDS.WALK
		player.go_to_jump_state()
		return

	if !player.is_on_floor():
		player.jump_count += 1
		player.go_to_fall_state()
		return

func crouch_state():

	if Input.is_action_just_released("crouch"):
		player.exit_crouch_state()
		player.go_to_idle_state()
		return
		
	if player.direction != 0:
		player.go_to_walk_crouch_state()
		return
	pass
	
func slide_state():
	if sliding_distance <= 0 or Input.is_action_just_released("slide"):
		player.exit_crouch_state()
		if player.direction != 0:
			if Input.is_action_pressed("run"):
				player.go_to_run_state()
			else:
				player.go_to_walk_state()
		else:
			player.go_to_idle_state()
		return
	
	if Input.is_action_just_pressed("jump"):
		player.exit_crouch_state()
		player.go_to_jump_state()
		return
