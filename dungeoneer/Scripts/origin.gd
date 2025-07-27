extends Node2D

func _ready() -> void:
	for x in range(-1, 2):
		for y in range(-1, 2):
			var offset = Vector2(x, y)
			if offset != Vector2.ZERO:
				print("rect")
				var rect : ColorRect = ColorRect.new()
				rect.size = Vector2(16, 16)
				rect.color = Color.WHITE
				rect.color.a = 0.5
				rect.position = offset * 16
				self.add_child(rect)

func _process(delta: float) -> void:
	if visible:
		var mouse_position = (get_global_mouse_position() - Vector2(8,8)).snappedf(16.0)
		for marker in self.get_children():
			if marker.global_position == mouse_position:
				marker.color.a = 1
			else:
				marker.color.a = 0.5
