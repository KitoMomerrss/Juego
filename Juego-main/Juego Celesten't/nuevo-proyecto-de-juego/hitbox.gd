class_name  Hitbox
extends Area2D

@export var damage : int = 10
 
@export var knockback = 600


func _ready() -> void:
	area_entered.connect(_on_hitbox_area_entered)
	
#func on_area_entered(area : Area2D) -> void:
#	if area.has_signal("on_hit"):
#		area.on_hit.emit(damage, self)
#	var hurtbox = area as Hurtbox
#	if hurtbox and hurtbox.owner.has_method("apply_knockback"):
#		area.owner.apply_knockback(owner.dash_direction, knockback)
#	pass

#func _on_Hitbox_body_entered(body):
#	if body.has_method("apply_knockback"):
#		body.apply_knockback(owner.dash_direction, knockback)
func _on_hitbox_area_entered(area):
	var hurtbox = area as Hurtbox
	if hurtbox:
		var enemy = area.get_parent() # Asumimos que Hurtbox es hijo del enemigo
		var player = get_parent()
		var direction = player.dash_direction
		enemy.apply_knockback(direction, knockback)
		Debug.log("ay")
