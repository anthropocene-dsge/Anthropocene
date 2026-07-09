extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -450.0

# Obtenemos la gravedad del proyecto
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta):
	# 1. Aplicar Gravedad
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. Salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 3. Movimiento Horizontal
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# 4. Ejecutar el movimiento
	move_and_slide()
	
	# 5. EFECTO PAC-MAN (Screen Wrap)
	var limites_pantalla = get_viewport_rect().size

	# Teletransporte Horizontal (Lados)
	if global_position.x > limites_pantalla.x:
		global_position.x = 0
	elif global_position.x < 0:
		global_position.x = limites_pantalla.x

	# Teletransporte Vertical (Si caes al vacío, apareces arriba)
	if global_position.y > limites_pantalla.y:
		global_position.y = 0
	elif global_position.y < 0:
		global_position.y = limites_pantalla.y
