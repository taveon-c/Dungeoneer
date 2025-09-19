extends Node2D
@export var level_info : LevelInfo

func generate_hint(color : Color, hint_position : Vector2):
	var rect : ColorRect = ColorRect.new()
	rect.size = Vector2(level_info.TILE_SIZE, level_info.TILE_SIZE)
	rect.color = color
	rect.color.a = 0.5
	add_child(rect)
	rect.global_position = hint_position - Vector2(level_info.TILE_SIZE/2, level_info.TILE_SIZE/2)

func clear_hints():
	for child in self.get_children():
		child.queue_free()
