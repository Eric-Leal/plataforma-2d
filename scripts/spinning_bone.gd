extends Area2D

@onready var animacao: AnimatedSprite2D = $AnimatedSprite2D
var speed = 60
var direction = 1




func _process(delta: float) -> void:
	position.x += speed * delta * direction
	
func set_direction(enemy_direction):
	self.direction = enemy_direction
	animacao.flip_h = direction < 0
		 
