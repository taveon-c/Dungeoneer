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
