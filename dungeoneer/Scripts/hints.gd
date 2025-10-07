extends Node2D
@export var hint_texture : Texture2D
@export var option_texture : Texture2D
@export var select_texture : Texture2D

var color
var select_color
var mouse_position
var hints = []
var options = []

func _draw() -> void:
	if mouse_position:
		draw_texture(select_texture, mouse_position - Vector2(8, 8), select_color)
	for pos in hints:
		draw_texture(hint_texture, pos - Vector2(8, 8), color)
	for pos in options:
		draw_texture(option_texture, pos - Vector2(8, 8), color)

func set_markers(color, options = [], hints = []):
	self.options = options
	self.hints = hints
	self.color = color
	queue_redraw()

func set_select(mouse_position, select_color):
	self.mouse_position = mouse_position
	self.select_color = select_color
	queue_redraw()

func clear():
	hints = []
	options = []
	queue_redraw()
