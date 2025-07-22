extends Control

@onready var Player = $"../../Player"
@onready var Menu_Action = $"../Action"
@onready var Origin : Control = $Origin
@onready var Path : Control = $"../Path"
@onready var Step_Label : Label = $Step
var path : Array[Vector2]
var is_moving : bool = false
@onready var current_pos = Player.position

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
				Origin.add_child(rect)

func _process(delta: float) -> void:
	if is_moving:
		var mouse_position =  (get_global_mouse_position() - Vector2(8,8)).snappedf(16.0)
		if Input.is_action_just_pressed("select"):
			for marker in Origin.get_children():
				if marker.global_position == mouse_position:
					Origin.global_position = mouse_position
					var rect : ColorRect = ColorRect.new()
					rect.size = Vector2(16, 16)
					rect.color = Color.DEEP_SKY_BLUE
					rect.color.a = 0.5
					rect.global_position = mouse_position
					Path.add_child(rect)
					Step_Label.text = "Step: " + str(Path.get_child_count())
		else:
			for marker in Origin.get_children():
				if marker.global_position == mouse_position:
					marker.color.a = 1
				else:
					marker.color.a = 0.5

func _on_move_pressed() -> void:
	self.visible = true
	Menu_Action.visible = false
	is_moving = true

func _on_exit_pressed() -> void:
	self.visible = false
	Menu_Action.visible = true
	is_moving = false

func _on_undo_pressed() -> void:
	if Path.get_child_count() > 0:
		var last = Path.get_child(Path.get_child_count()-1)
		Path.remove_child(last)
		last.queue_free()
		Step_Label.text = "Step: " + str(Path.get_child_count())
		if Path.get_child_count() > 0:
			Origin.global_position = Path.get_child(Path.get_child_count()-1).global_position
		else:
			Origin.global_position = Player.global_position
