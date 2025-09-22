extends Node2D
func generate_hint(color : Color, hint_position : Vector2):
	var rect : ColorRect = ColorRect.new()
	rect.size = Vector2(16, 16)
	rect.color = color
	rect.color.a = 0.5
	add_child(rect)
	rect.global_position = hint_position - Vector2(8, 8)

func clear_hints():
	for child in self.get_children():
		child.queue_free()
