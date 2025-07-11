extends Node

@onready var player_1: CharacterBody2D = $"Players/Player 1"
@onready var player_2: CharacterBody2D = $"Players/Player 2"

@onready var player_3: CharacterBody2D = $"Players/Player 3"
@onready var victory_screen: Control = $CanvasLayer/VictoryScreen

var stage_index: int
@export var powerup_scenes: Array[PackedScene]# ← asignás tu PowerUp.tscn desde el editor
@onready var power_ups: Node = $"Power-ups"


var powerups_location: Array[Vector2] = [
	Vector2(770, 470), Vector2(1356, 127), Vector2(770, 156), Vector2(762, 127), 
	Vector2(770, 664), Vector2(129, 308), Vector2(1487, 319), Vector2(229, 121),
	Vector2(1309, 121), Vector2(440, 618), Vector2(1144, 628), Vector2(788,384),
	Vector2(783, 104)
	]

@export var available_scenarios : Array[PackedScene]
var current_scenario : Node
@onready var stage: Node = $Stage

var types = ["damage", "dash", "heal"]
var chosen_type = types.pick_random()



func _ready():
	_resize()
	load_selected_scenario()
	victory_screen.visible = false
	
	var devices = Input.get_connected_joypads()

	if devices.size() >= 2:
		player_1.device_id = devices[0]
		player_2.device_id = devices[1]
	else:
		push_error("¡Conecta al menos dos mandos!")
	if not GlobalState.power_up:
		return
	if GlobalState.power_up:
		await get_tree().create_timer(10.0).timeout
		if stage_index == 0:
			spawn_random_powerup(powerups_location[randi_range(0,6)])
		if stage_index == 1:
			spawn_random_powerup(powerups_location[randi_range(7,12)])
		
func load_selected_scenario():
	var index = GlobalState.selected_scenario_index
	stage_index = index
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
	player_2.scale *= 0.75

func spawn_random_powerup(position: Vector2):
	
	
	var scene_index = randi_range(0,2)
	var powerup = powerup_scenes[scene_index].instantiate()
	powerup.position = position
	print("powerup")
	power_ups.add_child(powerup)
	await get_tree().create_timer(20.0).timeout
	if stage_index == 0:
		spawn_random_powerup(powerups_location[randi_range(0,6)])
	if stage_index == 1:
		spawn_random_powerup(powerups_location[randi_range(7,12)])
