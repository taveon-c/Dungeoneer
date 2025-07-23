extends CanvasLayer

@onready var Menu_Action : CanvasLayer = $"../Action"
@onready var Origin : Node2D = $"../Origin"
@onready var Path : Node = $"../Path"
var is_thrusting : bool = false

func _process(delta: float) -> void:
	if is_thrusting:
		var mouse_position =  (Origin.get_global_mouse_position() - Vector2(8,8)).snappedf(16.0)
		if Input.is_action_just_pressed("select"):
			for marker in Origin.get_children():
				if marker.global_position == mouse_position:
					var rect : ColorRect = ColorRect.new()
					rect.size = Vector2(16, 16)
					rect.color = Color.RED
					rect.color.a = 0.5
					rect.global_position = mouse_position
					Path.add_child(rect)
		else:
			for marker in Origin.get_children():
				if marker.global_position == mouse_position:
					marker.color.a = 1
				else:
					marker.color.a = 0.5

func _on_thrust_pressed() -> void:
	Menu_Action.visible = false
	self.visible = true
	Origin.visible = true
	is_thrusting = true

func _on_exit_pressed() -> void:
	Menu_Action.visible = true
	self.visible = false
	Origin.visible = false
	is_thrusting = false
