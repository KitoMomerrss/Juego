extends CharacterBody2D

@export var device_id: int = 0

#Movimiento basico
@export var speed = 300
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

var dash_pressed_last_frame = false
var jump_pressed = false

var knockback_time = 0
var is_knockback = false


#Dash
@export var dash_speed = 1300
var dash_time = 0.2  # Duración del dash en segundos
var is_dashing = false
var dash_direction = Vector2.ZERO
var dash_timer = 0.0
var can_dash = true


func _ready() -> void:
	pass
	


func _physics_process(delta: float) -> void:
	
	
	#probar mando
	var raw_x = Input.get_joy_axis(device_id, 0)
	var raw_y = Input.get_joy_axis(device_id, 1)
	
	var x = digital_axis(raw_x)
	var y = digital_axis(raw_y)

	var mando_direction = Vector2(x, y)
	
	#original
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
		#impide mantener precionado
		
		if dash_timer <= 0:
			is_dashing = false
			emit_signal("dash_end")
			velocity.y = 0
			# Resetea la rotación
			pivot.rotation = 0 
			sprite_flipper.scale.y = 1
	
	if is_knockback:
		knockback_time -= delta
		velocity = velocity.move_toward(Vector2.ZERO, delta * 500)
		if knockback_time <= 0.0:
			is_knockback = false
			
	else:
		# Movimiento normal
		#var move_input = Input.get_axis("1.Move.L", "1.Move.R")
		#velocity.x = move_toward(velocity.x, speed * move_input, acceleration * delta)
		
		#velocity.x = (Input.get_action_strength("1.Move.R") - Input.get_action_strength("1.Move.L")) * speed 
		if not is_dashing:
		#moverse con mando
			velocity.x = x  * speed 
			
		
		# Aplicar gravedad
			velocity.y += gravity*delta
		
		# Saltar
		
		#saltar mando solo
		#if is_on_floor() and Input.is_joy_button_pressed(device_id, 1):
		#	velocity.y = jump_force
			
		#if is_on_floor() and Input.is_action_just_pressed("1.Jump"):
		#	velocity.y = jump_force
		var jump_input = Input.is_joy_button_pressed(device_id, 1)
		if jump_input and not jump_pressed and is_on_floor():
			velocity.y = jump_force
			print("¡Jugador saltó!")
		jump_pressed = jump_input
		
		
		# Iniciar dash
		
		
		
		var dash_now = Input.is_joy_button_pressed(device_id, 0)
		if can_dash and ((dash_now and not dash_pressed_last_frame) or (Input.is_action_just_pressed("1.Dash"))):
			if mando_direction != Vector2.ZERO:
				start_dash(mando_direction)
			else:
				# Si no hay dirección presionada, dasha hacia donde está mirando el personaje (ejemplo: hacia la derecha)
				start_dash(Vector2(sprite_flipper.scale.x, 0))
		dash_pressed_last_frame = dash_now

	# Resetear dash al tocar el suelo
	if is_on_floor() and not is_dashing:
		can_dash = true

	#if move_input != 0 and not is_dashing:
	#	sprite_flipper.rotation = 0 #sign(move_input)
	
	move_and_slide()
	
	# Animaciones
	if x != 0:
		print(x)
		#sprite_flipper.scale.x = sign(move_input)
		sprite_flipper.scale.x = sign(x)
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
	dash_direction = direction
	velocity = dash_direction * dash_speed
	
		
	can_dash = true # Cambiar eventualmente


#funcion anti drift XD
func digital_axis(value: float, threshold := 0.5) -> int:
	if value > threshold:
		return value
	elif value < -threshold:
		return value
	return 0
