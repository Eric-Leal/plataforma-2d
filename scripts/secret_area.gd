extends TileMapLayer

func _on_detector_body_entered(_body: Node2D) -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.6, 0.3)

func _on_detector_body_exited(_body: Node2D) -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
