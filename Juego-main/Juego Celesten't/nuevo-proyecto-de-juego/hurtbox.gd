class_name Hurtbox
extends Area2D


@export var health : int = 100

#signal on_hit(damage : float, hitbox : Area2D)
#signal apply_knockback(hitbox : Area2D)

func _ready():
#	on_hit.connect(_on_hitbox_hit)
	pass
#func _on_hitbox_hit(damage : int, hitbox : Area2D):
	#manage damage animations and death signals here (I'm simplifying)
#	health -= damage 
	
	#sends the knockback signal to the player,
	#hitbox param is to define the direction of the knockback
#	apply_knockback.emit(hitbox)
	
	
	
	
	
	
	

	
	
