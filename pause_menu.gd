extends PanelContainer

@onready var resume: Button = $MarginContainer/VBoxContainer/Resume
@onready var restart: Button = $MarginContainer/VBoxContainer/Restart
@onready var main_menu: Button = $"MarginContainer/VBoxContainer/Main Menu"
@onready var quit: Button = $MarginContainer/VBoxContainer/Quit


func _ready() -> void:
	quit.pressed.connect(func(): get_tree().quit())
	restart.pressed.connect(_on_restart_pressed)
	main_menu.pressed.connect(_on_main_menu_pressed)
	resume.pressed.connect(_on_resume_pressed)
	hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pause"):
		get_tree().paused = not get_tree().paused
		visible = get_tree().paused

func _on_resume_pressed() -> void:
	get_tree().paused = false
	hide()
	
func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	
func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
