extends Control


@onready var rematch: Button = %Rematch
@onready var mainmenu: Button = %Mainmenu
@onready var label: Label = $Container/PanelContainer/Label



func _ready() -> void:
	rematch.pressed.connect(func(): get_tree().reload_current_scene())
	mainmenu.pressed.connect(func(): get_tree().change_scene_to_file("res://main_menu.tscn"))
