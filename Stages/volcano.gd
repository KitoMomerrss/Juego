extends Node2D

var start_pos := Vector2()
var end_pos := Vector2()
var up_time : float
func _ready():
	await get_tree().create_timer(5.0).timeout
	raise_lava()

func raise_lava():
	
	start_pos = Vector2(position.x, 25)
	end_pos = Vector2(position.x, altura())
	print(str(end_pos.y))

	position = start_pos
	
	var tween = create_tween()
	tween.tween_property(self, "position", end_pos, 5.0)
	await tween.finished
	await get_tree().create_timer(5.0).timeout
	lower_lava()

func lower_lava():
	var tween = create_tween()
	tween.tween_property(self, "position", start_pos, 5.0)
	await tween.finished
	await get_tree().create_timer(7.0).timeout
	raise_lava()
func altura():
	return randi_range(-680, -250)
	
