extends CharacterBody2D

#Movimiento basico
@export var speed = 200
@export var jump_force = -400
@export var gravity = 900
@export var acceleration = 1000

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
	else:
		# Movimiento normal
		#var move_input = Input.get_axis("1.Move.L", "1.Move.R")
		#velocity.x = move_toward(velocity.x, speed * move_input, acceleration * delta)
		
		velocity.x = (Input.get_action_strength("1.Move.R") - Input.get_action_strength("1.Move.L"))* speed
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
				start_dash(Vector2(1, 0))

	# Resetear dash al tocar el suelo
	if is_on_floor() and not is_dashing:
		can_dash = true

	move_and_slide()

func start_dash(direction):
	is_dashing = true
	can_dash = false
	dash_timer = dash_time
	dash_direction = direction.normalized()
	velocity = dash_direction * dash_speed
