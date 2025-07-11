class_name Hurtbox
extends Area2D


@onready var health_component: HealthComponent = $"../HealthComponent"

@export var health : int = 100


#signal on_hit(damage : float, hitbox : Area2D)
#signal apply_knockback(hitbox : Area2D)

func _ready():
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	var hitbox = area as Hitbox
	
	if hitbox and health_component:
		var player = hitbox.get_parent()
		if player as CharacterBody2D:
			health_component.take_damage(hitbox.damage * player.damage_multiplier)
			hitbox.damage_dealt.emit()
		else:
			health_component.take_damage(hitbox.damage)
			hitbox.damage_dealt.emit()


#func _on_hitbox_hit(damage : int, hitbox : Area2D):
	#manage damage animations and death signals here (I'm simplifying)
#	health -= damage 
	
	#sends the knockback signal to the player,
	#hitbox param is to define the direction of the knockback
#	apply_knockback.emit(hitbox)
	
	
	
	
	
	
	

	
	
