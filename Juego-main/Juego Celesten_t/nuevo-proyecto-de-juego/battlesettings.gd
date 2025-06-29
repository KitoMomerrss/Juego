extends Control

@onready var p_lay: Button = %PLay



func _ready() -> void:
	p_lay.pressed.connect(func(): get_tree().change_scene_to_file("res://main.tscn"))
