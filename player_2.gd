extends CharacterBody2D

#Movimiento basico
@export var speed = 200
@export var jump_force = -400
@export var gravity = 900
@export var acceleration = 1000

@onready var collision_shape_2d: CollisionShape2D = $Hitbox/CollisionShape2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree.get("parameters/playback")

@onready var pivot: Node2D = $Pivot




var knockback_time = 0
var is_knockback = false

@onready var hurtbox: Hurtbox = $Hurtbox











#Dash
@export var dash_speed = 600
var dash_time = 0.2  # Duración del dash en segundos
var is_dashing = false
var dash_direction = Vector2.ZERO
var dash_timer = 0.0
var can_dash = true


func _ready() -> void:
#	hurtbox.apply_knockback.connect(_player_apply_knockback)
	pass
	


	
	
func _physics_process(delta: float) -> void:
	
	#Daño
	var move_input = Input.get_axis("2.move.L", "2.move.R")
	
	var input_direction = Vector2.ZERO

	# Detectar inputs de movimiento
	#input_direction.x = Input.get_action_strength("1.Move.R") - Input.get_action_strength("1.Move.R")
	input_direction.x = Input.get_axis("2.move.L", "2.move.R")
	input_direction.y = Input.get_action_strength("2.move.D") - Input.get_action_strength("2.move.U")
	input_direction = input_direction.normalized()
	
	
	
		
	if is_dashing:
		# Durante el dash, nos movemos solo en la dirección del dash
		velocity = dash_direction * dash_speed
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
	
	#estar en knocback
	#if knocked_timeout > 0:
		#for a certain timeout the player can't move the character or jump
	#	knocked_timeout -= delta
	if is_knockback:
		knockback_time -= delta
		velocity = velocity.move_toward(Vector2.ZERO, delta * 500)
		if knockback_time <= 0.0:
			is_knockback = false	
		
		
		
	else:
		# Movimiento normal
		#var move_input = Input.get_axis("1.Move.L", "1.Move.R")
		#velocity.x = move_toward(velocity.x, speed * move_input, acceleration * delta)
		
		velocity.x = (Input.get_action_strength("2.move.R") - Input.get_action_strength("2.move.L"))* speed
		#velocity.x = speed
		# Aplicar gravedad
		velocity.y += gravity*delta

		# Saltar
		if is_on_floor() and Input.is_action_just_pressed("2.jump"):
			velocity.y = jump_force

		# Iniciar dash
		if can_dash and Input.is_action_just_pressed("2.dash"):
			if input_direction != Vector2.ZERO:
				start_dash(input_direction)
			else:
				# Si no hay dirección presionada, dasha hacia donde está mirando el personaje (ejemplo: hacia la derecha)
				start_dash(Vector2(1, 0))

	# Resetear dash al tocar el suelo
	if is_on_floor() and not is_dashing:
		can_dash = true

	
	move_and_slide()
	#animaciones
	if move_input != 0:
		pivot.scale.x = sign(move_input)
	if is_on_floor():
		if abs(velocity.x) > 30:
			playback.travel("RUN")
		else:
			playback.travel("Idle")
	
	else:
		if velocity.y < 0:
			playback.travel("jump")
		else:
			playback.travel("fall")
	if is_dashing == true:
		playback.travel("dash")
	

#funciones knocback	
#func _player_apply_knockback(enemyHitbox: Area2D):
#	var knockback_direction : Vector2 = Vector2(1 , 1).normalized()
	
#	velocity = knockback_direction * knockback_power
#	knocked_timeout = .4
	
func apply_knockback(direction: Vector2, force: float):
	var knockback_velocity = direction.normalized() * force
	velocity = knockback_velocity  # si usas physics-based movement
	is_knockback = true
	knockback_time = 0.5 # segundos de knockback
	Debug.log("por que no vuela")




func start_dash(direction):
	is_dashing = true
	can_dash = false
	dash_timer = dash_time
	dash_direction = direction.normalized()
	velocity = dash_direction * dash_speed


func get_hit(knockback: int) -> void:
	velocity.y = -knockback
	velocity.x = knockback
	get_yeet()
	
func get_yeet() -> void:
	#set_physics_process(false)
	playback.travel("Hit")
	print("aaa")
	await animation_tree.animation_finished
	#si_physics()
#func si_physics():
	set_physics_process(true)
	
	
