class_name PowerUp
extends Area2D

@export var type: String = "dash"  

func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))
	await get_tree().create_timer(15.0).timeout
	queue_free()
func _on_area_entered(area):
	if area as Hurtbox:
		var player = area.get_parent()
		if player.has_method("apply_powerup"):
			player.apply_powerup(type)
			queue_free()
