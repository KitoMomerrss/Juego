extends Node

@onready var player_1: CharacterBody2D = $"Players/Player 1"
@onready var player_2: CharacterBody2D = $"Players/Player 2"
@onready var player_3: CharacterBody2D = $"Players/Player 3"
@onready var victory_screen: Control = $CanvasLayer/VictoryScreen




@export var available_scenarios : Array[PackedScene]
var current_scenario : Node
@onready var stage: Node = $Stage


func _ready():
	_resize()
	load_selected_scenario()
	victory_screen.visible = false
	
	var devices = Input.get_connected_joypads()

	if devices.size() >= 2:
		player_1.device_id = devices[0]
		player_3.device_id = devices[1]
	else:
		push_error("¡Conecta al menos dos mandos!")
	
	

func load_selected_scenario():
	var index = GlobalState.selected_scenario_index
	
	if index >= 0 and index < available_scenarios.size():
		var scenario_instance = available_scenarios[index].instantiate()
		$Stage.add_child(scenario_instance)
	else:
		push_error("Índice de escenario inválido: " + str(index))
	
		
func game_progress() -> void:
	
	if player_1.loser:
		victory_screen.visible = true
		victory_screen.label.text = "Player 2 Wins!!!"
	if player_3.loser:
		victory_screen.visible = true
		victory_screen.label.text = "Player 1 Wins!!!"
func _resize() -> void:
	player_1.scale *= 0.75
	player_3.scale *= 0.75
