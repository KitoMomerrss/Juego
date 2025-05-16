extends CharacterBody2D

@export var device_id: int = 0

# Movimiento básico
@export var speed = 200
@export var jump_force = -400
@export var gravity = 900
@export var acceleration = 1000

# Dash
@export var dash_speed = 600
var dash_time = 0.2
var is_dashing = false
var dash_direction = Vector2.ZERO
var dash_timer = 0.0
var can_dash = true

# Knockback
var knockback_time = 0
var is_knockback = false

# Estados de botones
var dash_pressed_last_frame = false
var jump_pressed = false

# Referencias
@onready var collision_shape_2d: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var playback = animation_tree.get("parameters/playback")
@onready var pivot: Node2D = $Pivot
@onready var sprite_flipper: Node2D = $Pivot/SpriteFlipper
@onready var hurtbox: Hurtbox = $Hurtbox

func _physics_process(delta: float) -> void:
	# --- ENTRADAS ---
	var raw_x = Input.get_joy_axis(device_id, JOY_AXIS_LEFT_X)
	var raw_y = Input.get_joy_axis(device_id, JOY_AXIS_LEFT_Y)
	var x = digital_axis(raw_x)
	var y = digital_axis(raw_y)
	var mando_direction = Vector2(x, y).normalized()

	var jump_now = Input.is_joy_button_pressed(device_id, JOY_BUTTON_B)  # botón 1
	var dash_now = Input.is_joy_button_pressed(device_id, JOY_BUTTON_A)  # botón 0

	# --- DASH ---
	if is_dashing:
		velocity = dash_direction * dash_speed
		dash_timer -= delta
		if dash_timer <= 0.0:
			is_dashing = false
			emit_signal("dash_end")
			velocity.y = 0
			pivot.rotation = 0
			sprite_flipper.scale.y = 1
	else:
		# --- KNOCKBACK ---
		if is_knockback:
			knockback_time -= delta
			velocity = velocity.move_toward(Vector2.ZERO, delta * 500)
			if knockback_time <= 0.0:
				is_knockback = false
		else:
			# Movimiento horizontal normal
			velocity.x = x * speed

			# --- Salto ---
			# Se asegura de que solo se aplique si estamos en el suelo
			if jump_now and not jump_pressed and is_on_floor():
				velocity.y = jump_force
				print("¡Jugador saltó!")

	# --- Gravedad ---
	if not is_on_floor() and not is_dashing:
		velocity.y += gravity * delta
	elif is_on_floor() and not is_dashing:
		velocity.y = 0

	# --- Resetear dash si estás en el suelo ---
	if is_on_floor() and not is_dashing:
		can_dash = true

	# --- Manejo de Dash ---
	if can_dash and dash_now and not dash_pressed_last_frame and is_on_floor():
		if mando_direction != Vector2.ZERO:
			start_dash(mando_direction)
		else:
			start_dash(Vector2(sprite_flipper.scale.x, 0))

	# Guardar estados de botones
	jump_pressed = jump_now
	dash_pressed_last_frame = dash_now

	# --- Movimiento y colisiones ---
	move_and_slide()  # Es importante usar "Vector2.UP" para las colisiones con el suelo

	# --- ANIMACIONES ---
	if x != 0:
		sprite_flipper.scale.x = sign(x)

	if is_dashing:
		playback.travel("dash")
	elif is_on_floor():
		if abs(velocity.x) > 30:
			playback.travel("RUN")
		else:
			playback.travel("Idle")
	else:
		if velocity.y < 0:
			playback.travel("jump")
		else:
			playback.travel("fall")

# --- FUNCIONES AUXILIARES ---

func start_dash(direction: Vector2) -> void:
	is_dashing = true
	can_dash = false
	dash_timer = dash_time
	dash_direction = direction.normalized()
	velocity = dash_direction * dash_speed

func apply_knockback(direction: Vector2, force: float):
	var knockback_velocity = direction.normalized() * force
	velocity = knockback_velocity
	is_knockback = true
	knockback_time = 0.5

func digital_axis(value: float, threshold := 0.5) -> int:
	if value > threshold:
		return 1
	elif value < -threshold:
		return -1
	return 0
