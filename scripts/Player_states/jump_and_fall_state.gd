extends Node

@onready var player: CharacterBody2D = owner

func _ready():
	pass

func update(_delta):
	match player.status:
		player.PlayerState.jump:
			jump_state()
		player.PlayerState.fall:
			fall_state()
				
				
func fall_state():
	
	if Input.is_action_just_pressed("jump") && player.can_jump():
		player.go_to_jump_state()
		return
	
	if player.is_on_floor():
		player.jump_count = 0
		if player.velocity.x == 0:
			player.go_to_idle_state()
		else:
			player.go_to_walk_state()
		return
		

func jump_state():
	if Input.is_action_just_pressed("jump") && player.can_jump():
		player.go_to_jump_state()
		return

	if player.velocity.y > 0:
		player.go_to_fall_state()
		return
	
	if Input.is_action_just_pressed("slide") && player.can_slide() && player.current_speed >= player.SPEEDS.RUN:
			player.go_to_slide_state(25)
			return
