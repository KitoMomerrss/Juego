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
@onready var health_bar: ProgressBar = $CanvasLayer/MarginContainer/HealthBar
@onready var label: Label = $CanvasLayer/MarginContainer/MarginContainer/Label



@onready var health_component: HealthComponent = $HealthComponent


var dead = false
var respawn_position: Vector2
var stocks = 3
var loser = false

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
	if respawn_position == Vector2.ZERO:
		respawn_position = global_position
	health_component.health_changed.connect(_on_health_changed)
	health_bar.value = health_component.health
	health_component.died.connect(death)
	label.text = " %d " %stocks
	 
func _on_health_changed(value: float) -> void:
	
	health_bar.value = value
	
func death() -> void:
	if stocks > 0:
		stocks -= 1
		dead = true
		is_knockback = false
		
		label.text = " %d " %stocks
		#if stocks = 0:
		#	get.tree...
		#	queue.free()
	
		respawn()
	if stocks == 0:
		lost()
		queue_free()
		
		
	
func respawn() -> void:
	
	is_knockback = false
	velocity *= 0
	dead = false
	health_component.health = health_component.max_health
	global_position = respawn_position

func lost() -> void:
	print("loserxd")
	loser = true
	get_parent().game_progress()
	

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
	
	
	if dead:
		velocity = velocity * 0
	if is_dashing:
		# Durante el dash, nos movemos solo en la dirección del dash
		velocity = dash_direction * dash_speed 
		dash_timer -= delta
		#impide mantener precionado
		
		if dash_timer <= 0:
			is_dashing = false
			velocity.y = 0
			# Resetea la rotación
			pivot.scale.x = 1 
			pivot.rotation = 0
	
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
		if not is_dashing and not is_knockback:
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
				start_dash(Vector2(pivot.scale.x, 0))
		dash_pressed_last_frame = dash_now

	# Resetear dash al tocar el suelo
	if is_on_floor() and not is_dashing:
		can_dash = true

	#if move_input != 0 and not is_dashing:
	#	sprite_flipper.rotation = 0 #sign(move_input)
	
	move_and_slide()
	
	# Animaciones
	if x != 0:
		#sprite_flipper.scale.x = sign(move_input)
		pivot.scale.x = sign(x) # huh
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
	


func start_dash(direction: Vector2):
	is_dashing = true
	can_dash = false
	dash_timer = dash_time
	# Inputs stick análogo 360 deg
	var raw_x = Input.get_joy_axis(device_id, 0)
	var raw_y = Input.get_joy_axis(device_id, 1)
	
	dash_direction = Vector2(raw_x, raw_y) # Dirección dash
	velocity = dash_direction * dash_speed # Dash

	# ROTACIÓN VISUAL limpia
	pivot.rotation = dash_direction.angle()

	# Fix manual del lado izquierdo que gira y flipea raro :(
	if pivot.rotation <= -2 or 2 <= pivot.rotation:
		pivot.rotation = dash_direction.angle() - PI

	can_dash = true # CAMBIAR A FALSE EVENTUALMENTE


#funcion anti drift XD
func digital_axis(value: float, threshold := 0.5) -> int:
	if value > threshold:
		return value
	elif value < -threshold:
		return value
	return 0
	
