class_name HealthComponent
extends Node

signal died
signal health_changed(value)

var regen_timer: float = 0.0

@export var health: float = 100:
	set(value):
		if health == value:
			return
		health = clamp(value, 0, max_health)
		health_changed.emit(health)
		if health == 0:
			died.emit()
@export var max_health: float = 100


func take_damage(damage):
	health -= damage
	
	
func _process(delta):
	regen_timer += delta
	if regen_timer >= 0.3:
		regen_timer = 0.0
		health = min(health + 1, max_health)
	
