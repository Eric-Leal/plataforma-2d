extends Camera2D

var target: Node2D

func _ready() -> void:
	getTarget()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.

func _process(_delta: float) -> void:
	position = target.position


func getTarget():
	var nodes = get_tree().get_nodes_in_group("Player")
	
	if nodes.size() == 0:
		push_error("Player not found")
		return
	
	target = nodes[0]
