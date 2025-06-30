extends Control

@onready var p_lay: Button = %PLay

var stocks = GlobalState.starting_lives
@onready var vidas: Label = $MarginContainer3/PanelContainer/Vidas
@onready var menos_stock: Button = %MenosStock
@onready var mas_stock: Button = %MasStock

@onready var si_pu: Button = %SiPU
@onready var no_pu: Button = %NoPU

@onready var stage_1: Button = %Stage1
@onready var stage_2: Button = %Stage2


func _ready() -> void:
	$MarginContainer3/PanelContainer/Vidas.text = str(GlobalState.starting_lives)
	p_lay.pressed.connect(func(): get_tree().change_scene_to_file("res://game_manager.tscn"))
	
	stage_1.pressed.connect(func(): _on_stage_button_pressed(0))
	stage_2.pressed.connect(func(): _on_stage_button_pressed(1))
	
	
	menos_stock.pressed.connect(func(): _minus_stock())
	mas_stock.pressed.connect(func(): _add_stock())
	
	
	
func _on_stage_button_pressed(stage_index):
	GlobalState.selected_scenario_index = stage_index
	print("escenario")
	print(" %d " %GlobalState.selected_scenario_index)
	
func _add_stock():
	
	if GlobalState.starting_lives < 99:
		GlobalState.starting_lives += 1
		print(str(GlobalState.starting_lives))
	else:
		pass
	update_lives_label()
func _minus_stock():
	
	if GlobalState.starting_lives > 1:
		GlobalState.starting_lives -= 1
		print(str(GlobalState.starting_lives))
	else:
		pass
	update_lives_label()
func update_lives_label():
	$MarginContainer3/PanelContainer/Vidas.text = str(GlobalState.starting_lives)

	
