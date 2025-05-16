extends Node2D

@onready var player_1: CharacterBody2D = $"Player 1"
@onready var player_2: CharacterBody2D = $"Player 2"


func _ready():
	var devices = Input.get_connected_joypads()

	if devices.size() >= 2:
		player_1.device_id = devices[0]
		player_2.device_id = devices[1]
	else:
		push_error("¡Conecta al menos dos mandos!")
		
		
func _process(delta):
	var device_id = 0  # Cambia esto por el mando que quieras probar

	for i in range(20):
		if Input.is_joy_button_pressed(device_id, i):
			#print("Botón presionado:", i)
			pass
	for i in range(8):
		var value = Input.get_joy_axis(device_id, i)
		if abs(value) > 0.1:
			#print("Eje", i, "valor:", value)
			pass
