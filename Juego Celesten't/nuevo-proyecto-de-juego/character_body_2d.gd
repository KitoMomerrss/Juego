extends CharacterBody2D

@export var MAX_SPEED = 400
@export var acceleration = 4500
@export var gravity = 1000
@export var jump_speed = 610

func _ready() -> void:
	pass
	
func _physics_process(delta: float) -> void:
	
	if is_on_floor() and Input.is_action_just_pressed("1.Jump"):
		velocity.y = -jump_speed
	if not is_on_floor():
		velocity.y += gravity * delta
		
	var move_input = Input.get_axis("1.Move.L", "1.Move.R")
	
	velocity.x = move_toward(velocity.x, MAX_SPEED * move_input, acceleration * delta)
	move_and_slide()
	
