extends Node2D

func generate_hint(color : Color, position : Vector2):
	var rect : ColorRect = ColorRect.new()
	rect.size = Vector2(16, 16)
	rect.color = color
	rect.color.a = 0.5
	rect.global_position = position
	add_child(rect)

func clear_hints():
	for child in self.get_children():
		child.queue_free()
