extends Node

@onready var player: CharacterBody2D = owner

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func update(_delta):
	match player.status:
		player.PlayerState.walk:
			walk_state()
		player.PlayerState.run:
			run_state()
			
			
func walk_state():
	
	if player.direction == 0:
		player.go_to_idle_state()
		return
		
	if Input.is_action_just_pressed("jump"):
		player.go_to_jump_state()
		return
		
	if Input.is_action_pressed("crouch"):
		player.go_to_walk_crouch_state()
		return
		
	if !player.is_on_floor():
		player.jump_count += 1
		player.go_to_fall_state()
		return

	if Input.is_action_pressed("run"):
		player.go_to_run_state()
		return
		
	if Input.is_action_just_pressed("slide") && player.can_slide():
		player.go_to_slide_state(10)
		return
	
	
	
func run_state():

	if Input.is_action_just_pressed("jump"):
		player.go_to_jump_state()
		return
	
	if Input.is_action_just_released("run"):
		player.go_to_walk_state()
		return	
	
	if player.direction == 0:
		player.go_to_idle_state()
		return

	if Input.is_action_pressed("crouch"):
		player.go_to_walk_crouch_state()
		return
	
	if !player.is_on_floor():
		player.jump_count += 1
		player.go_to_fall_state()
		return

	if Input.is_action_just_pressed("slide") && player.can_slide() :
		player.go_to_slide_state(45)
		return
