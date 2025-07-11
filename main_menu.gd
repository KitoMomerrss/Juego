extends Node

@onready var start: Button = %start
@onready var credits: Button = %credits
@onready var quit: Button = %quit

@onready var player_1: CharacterBody2D = $"Player 1"
@onready var player_2: CharacterBody2D = $"Player 2"


func _ready() -> void:
	start.pressed.connect(func(): get_tree().change_scene_to_file("res://battlesettings.tscn"))
	credits.pressed.connect(func(): get_tree().change_scene_to_file("res://creditscreen.tscn"))
	quit.pressed.connect(func(): get_tree().quit())
	
