class_name HitFlash
extends Node

func hit_flash(intensity: float = 0.3, duration: float = 0.1) -> void:
	# Screen-space red flash via CanvasModulate or shader
	var modulate = get_viewport().get_canvas_modulate()
	if not modulate:
		modulate = CanvasModulate.new()
		get_viewport().add_child(modulate)
	
	var tween = create_tween()
	tween.tween_property(modulate, "color", Color(1, 0, 0, intensity), duration * 0.5)
	tween.tween_property(modulate, "color", Color(1, 1, 1, 0), duration * 0.5)