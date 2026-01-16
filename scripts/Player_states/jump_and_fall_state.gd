extends Node

@onready var player: CharacterBody2D = owner

func _ready():
	pass

func update(_delta):
	match player.status:
		player.PlayerState.jump:
			if Input.is_action_just_pressed("jump") and player.can_jump():
				player.go_to_jump_state()
			elif player.velocity.y > 0:
				player.go_to_fall_state()

		player.PlayerState.fall:
			if Input.is_action_just_pressed("jump") and player.can_jump():
				player.go_to_jump_state()
			elif player.is_on_floor():
				player.jump_count = 0
				if player.velocity.x == 0: player.go_to_idle_state()
				else: player.go_to_walk_state()
