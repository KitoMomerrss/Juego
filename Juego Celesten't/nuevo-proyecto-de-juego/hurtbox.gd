class_name Hurtbox
extends Area2D

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	
func _on_area_entered(area: Area2D) -> void:
	var hitbox = area as Hitbox
	if hitbox:
		if owner.has_method("get_hit"):
				owner.get_hit(hitbox.knockback)
				
			
	Debug.log("Hurtbox")
	Debug.log(area)
	pass
	
