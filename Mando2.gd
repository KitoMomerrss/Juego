extends CharacterBody2D

@export var device_id: int = 0

#Movimiento basico
@export var speed = 300
@export var jump_force = -400
@export var gravity = 900
@export var acceleration = 1000

@onready var collision_shape_2d: CollisionShape2D = $Hitbox/CollisionShape2D

@onready var player_collision_shape_2d: CollisionShape2D = $CollisionShape2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree.get("parameters/playback")

@onready var pivot: Node2D = $Pivot
@onready var sprite_flipper: Node2D = $Pivot/SpriteFlipper
@onready var walljumpdetection: RayCast2D = $Pivot/SpriteFlipper/walljumpdetection


@onready var hurtbox_2: Hurtbox2 = $Hurtbox2
@onready var health_bar: ProgressBar = $CanvasLayer/MarginContainer/HealthBar
@onready var label: Label = $CanvasLayer/MarginContainer/MarginContainer/Label



@onready var health_component_2: HealthComponent2 = $HealthComponent2



var dead = false
var respawn_position: Vector2
var stocks : int
var loser = false

var dash_pressed_last_frame = false
var jump_pressed = false
var jump_just_pressed := false
var walljump_pressed = false

var knockback_time = 0
var is_knockback = false

var state = State.MOVEMENT:
	set = set_state 


#Dash
@export var dash_speed = 1300
var dash_time = 0.2  # Duración del dash en segundos
var is_dashing = false
var dash_direction = Vector2.ZERO
var dash_timer = 0.0
var can_dash = true

enum State {
	MOVEMENT,
	WALL_JUMP
}

func _ready() -> void:
	stocks = GlobalState.starting_lives
	label.text = " %d " %stocks
	
	if respawn_position == Vector2.ZERO:
		respawn_position = global_position
	health_component_2.health_changed.connect(_on_health_changed)
	health_bar.value = health_component_2.health
	health_component_2.died.connect(death)
	
	
	 
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
	health_component_2.health = health_component_2.max_health
	global_position = respawn_position

func lost() -> void:
	print("loserxd")
	loser = true
	get_parent().get_parent().game_progress()
	

func _physics_process(delta: float) -> void:
	match state:
		State.MOVEMENT:
			_movement(delta)
		State.WALL_JUMP:
			_wall_jump(delta)



func _movement(delta: float) -> void:
	
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
			velocity = Vector2.ZERO
			# Resetea la rotación
			pivot.scale.x = sign(raw_x)
			pivot.rotation = 0
	
	if is_knockback:
		knockback_time -= delta
		#velocity = velocity.move_toward(Vector2.ZERO, delta * 500)
		if knockback_time <= 0.0:
			is_knockback = false
			
	else:
		if not is_on_floor() and walljumpdetection.is_colliding():
			if is_dashing == true: # Esto arregla un poco el walljump desde dash diagonal
				pivot.scale.x = sign(raw_x)
				pivot.rotation = 0
			state = State.WALL_JUMP
			
		 
		if not is_dashing and not is_knockback:
		#moverse con mando
			velocity.x = move_toward(velocity.x, speed * x, delta * acceleration)
			#velocity.x = x  * speed
			
		# Aplicar gravedad
			velocity.y += gravity*delta
		
		var jump_input = Input.is_joy_button_pressed(device_id, 1)
		if jump_input and not jump_pressed and is_on_floor():
			velocity.y = jump_force
			#print("¡Jugador saltó!")
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
		

func _wall_jump(delta: float) -> void:
	
	is_dashing = false
	
	var wall_timer = 0.4
	#if not walljumpdetection.is_colliding():
	#	state = State.MOVEMENT
	playback.travel("wall slide")
	velocity.y += 0.1 * gravity * delta
	move_and_slide()
	
	jump_just_pressed = Input.is_joy_button_pressed(device_id, 1)
	if jump_just_pressed and not walljump_pressed:
		print("walljump")
		pivot.scale.x *= -1
		playback.travel("wall jump")
		velocity.y = jump_force
		velocity.x = - sign(pivot.scale.x) *  jump_force
		wall_timer -= delta/10
		if wall_timer <= 0:
			state = State.MOVEMENT
		can_dash = true # Posibilidad de hacer dash luego de walljump
	if not walljumpdetection.is_colliding():
		state = State.MOVEMENT
		
	if is_on_floor():
		state = State.MOVEMENT
	
	walljump_pressed = jump_just_pressed

func apply_knockback(direction: Vector2, force: float):
	var knockback_velocity = direction.normalized() * force
	velocity = knockback_velocity  # si usas physics-based movement
	is_knockback = true
	can_dash = true 	# Posibilidad de hacer dash luego de acertar un ataque
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

	can_dash = false # CAMBIAR A TRUE SOLO PARA DEBUG


#funcion anti drift XD
func digital_axis(value: float, threshold := 0.5) -> int:
	if value > threshold:
		return value
	elif value < -threshold:
		return value
	return 0
	
func set_state(value: State) -> void:
	var old_state = state
	var new_state = value
	
	
	state = new_state
	
	if new_state == State.WALL_JUMP:
		var collision_point = walljumpdetection.get_collision_point()
		global_position.x = collision_point.x + player_collision_shape_2d.shape.radius * sign(sprite_flipper.scale.x)
		velocity = Vector2.ZERO
