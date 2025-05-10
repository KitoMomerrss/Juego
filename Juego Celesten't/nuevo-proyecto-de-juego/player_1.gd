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
@onready var sprite_flipper: Node2D = $Pivot/SpriteFlipper



@onready var hurtbox: Hurtbox = $Hurtbox



#Dash
@export var dash_speed = 600
var dash_time = 0.2  # Duración del dash en segundos
var is_dashing = false
var dash_direction = Vector2.ZERO
var dash_timer = 0.0
var can_dash = true


func _ready() -> void:
	pass
	


func _physics_process(delta: float) -> void:
	
	#Daño
	var move_input = Input.get_axis("1.Move.L", "1.Move.R")
	
	var input_direction = Vector2.ZERO

	# Detectar inputs de movimiento
	#input_direction.x = Input.get_action_strength("1.Move.R") - Input.get_action_strength("1.Move.R")
	input_direction.x = Input.get_axis("1.Move.L", "1.Move.R")
	input_direction.y = Input.get_action_strength("1.Move.D") - Input.get_action_strength("1.Move.U")
	input_direction = input_direction.normalized()
	
	
	
		
	if is_dashing:
		# Durante el dash, nos movemos solo en la dirección del dash
		velocity = dash_direction * dash_speed 
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
			emit_signal("dash_end")
			velocity.y = 0
			# Resetea la rotación
			pivot.rotation = 0 
			sprite_flipper.scale.y = 1
	else:
		# Movimiento normal
		#var move_input = Input.get_axis("1.Move.L", "1.Move.R")
		#velocity.x = move_toward(velocity.x, speed * move_input, acceleration * delta)
		
		velocity.x = (Input.get_action_strength("1.Move.R") - Input.get_action_strength("1.Move.L")) * speed 
		#velocity.x = speed
		# Aplicar gravedad
		velocity.y += gravity*delta

		# Saltar
		if is_on_floor() and Input.is_action_just_pressed("1.Jump"):
			velocity.y = jump_force

		# Iniciar dash
		if can_dash and Input.is_action_just_pressed("1.Dash"):
			if input_direction != Vector2.ZERO:
				start_dash(input_direction)
			else:
				# Si no hay dirección presionada, dasha hacia donde está mirando el personaje (ejemplo: hacia la derecha)
				start_dash(Vector2(sprite_flipper.scale.x, 0))

	# Resetear dash al tocar el suelo
	if is_on_floor() and not is_dashing:
		can_dash = true

	#if move_input != 0 and not is_dashing:
	#	sprite_flipper.rotation = 0 #sign(move_input)
	
	move_and_slide()
	
	# Animaciones
	if move_input != 0:
		sprite_flipper.scale.x = sign(move_input)
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
		


func start_dash(direction):
	is_dashing = true
	can_dash = false
	dash_timer = dash_time
	dash_direction = direction.normalized()
	velocity = dash_direction * dash_speed
	
	# Rotar el Pivot al ángulo del dash
	pivot.rotation = dash_direction.angle()
	print(pivot.rotation)
	
	if abs(pivot.rotation) > 1.57079637050629: # Si dasheamos hacia la izq
		sprite_flipper.scale.y = -1
		sprite_flipper.scale.x = -1
		print("rotacion")

	# Flip visual: solo el flipper cambia su scale.x
	#if abs(dash_direction.x) > 0.1:
	#	sprite_flipper.scale.x = sign(dash_direction.x)
		
	can_dash = true # Cambiar eventualmente

'''
if 1.57079637050629 < pivot.rotation and pivot.rotation < -1.57079637050629:
		sprite_flipper.scale.y = -1
		print("asd")
'''


func get_hit(knockback: int) -> void:
	velocity.y = - knockback
	velocity.x = knockback
	get_yeet()
	
func get_yeet() -> void:
	#set_physics_process(false)
	playback.travel("Hit")
	print("aaa")
	#await animation_tree.animation_finished
	#si_physics()
#func si_physics():
	set_physics_process(true)
	



	
