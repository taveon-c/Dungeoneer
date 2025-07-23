extends Node2D
var turn : bool = false
@onready var timer : Timer = $Timer
@onready var Player = $Player
@onready var Path = $Path
@onready var Action  =$Action

func _on_submit_pressed() -> void:
	Action.visible = false
	timer.start()

func _on_timer_timeout() -> void:
	if Path.get_child_count() > 0:
		var next_step = Path.get_child(0)
		var move_color = Color.DEEP_SKY_BLUE
		move_color.a = 0.5
		if next_step.color == move_color:
			Player.global_position = next_step.global_position
		Path.remove_child(next_step)
		next_step.queue_free()
	else:
		Action.visible = true
		timer.stop()
