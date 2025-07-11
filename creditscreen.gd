extends Control

@onready var back: Button = $Back

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	back.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
