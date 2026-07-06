extends CharacterBody2D

const SPEED = 300.0

func _physics_process(delta):
	# Detecta las 4 flechas del teclado de forma nativa
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Si hay dirección, aplica la velocidad
	if direction:
		velocity = direction * SPEED
	else:
		# Si no tocas nada, se detiene por completo
		velocity = Vector2.ZERO

	# Ejecuta el movimiento sin aplicar gravedad
	move_and_slide()
