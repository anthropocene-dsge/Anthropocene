extends CharacterBody2D

# VARIABLES DE FÍSICA BÁSICA
const SPEED = 300.0 
const JUMP_VELOCITY = -400.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# CONFIGURACIÓN DE DIFICULTAD
# Hambre
var desgaste_hambre: float = 0.5 
var daño_inanicion: float = 1.0 

# Radiación
var incremento_radiacion: float = 0.5 # Cuánta radiación absorbe del ambiente por tick
var daño_radiacion: float = 2.0 # Cuánta vida pierde si llega al 100% de radiación

var timer_metabolismo: Timer
var mirando_derecha: bool = true

func _ready():
	# Leer las coordenadas del portal
	# Si la coordenada no es cero, nos movemos ahí inmediatamente
	if Global.posicion_jugador_al_entrar != Vector2.ZERO:
		global_position = Global.posicion_jugador_al_entrar
		
		# Limpiamos la variable para que si mueres y revives, no te mande al portal
		Global.posicion_jugador_al_entrar = Vector2.ZERO 
	
	timer_metabolismo = Timer.new()
	timer_metabolismo.wait_time = 10.0 # <--- Cambiado de 5.0 a 10.0 segundos
	timer_metabolismo.timeout.connect(_procesar_metabolismo)
	add_child(timer_metabolismo)
	timer_metabolismo.start()

func _physics_process(delta):
	# 1. APLICAR GRAVEDAD
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. SALTO
	if Input.is_action_just_pressed("ui_accept") and is_on_floor(): 
		velocity.y = JUMP_VELOCITY

	# 3. MOVIMIENTO Y ANIMACIÓN
	var direction = Input.get_axis("move_left", "move_right")
	
	if direction > 0:
		velocity.x = direction * SPEED
		mirando_derecha = true
		$AnimatedSprite2D.play("derecha")
	elif direction < 0:
		velocity.x = direction * SPEED
		mirando_derecha = false
		$AnimatedSprite2D.play("izquierda")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if abs(velocity.x) < 10:
			if mirando_derecha:
				$AnimatedSprite2D.play("idle derecha")
			else:
				$AnimatedSprite2D.play("idle izquierda")
			
	# IMPORTANTE: Mover al personaje con todas las físicas calculadas
	move_and_slide()

	# 4. CONTROLES DE SUPERVIVENCIA
	if Input.is_action_just_pressed("comer"): 
		intentar_comer()

# SISTEMA DE METABOLISMO
func _procesar_metabolismo():
	# 1. PROCESAR HAMBRE
	if Global.hambre_actual > 0:
		Global.hambre_actual -= desgaste_hambre
		if Global.hambre_actual < 0:
			Global.hambre_actual = 0
			
		# REGENERACIÓN: Si estás bien alimentado (>80), te curas poco a poco
		if Global.hambre_actual >= 80 and Global.salud_actual < 100:
			Global.salud_actual += 2.0 # Recuperas 2 de vida por tick
			if Global.salud_actual > 100:
				Global.salud_actual = 100.0
			print("Bien alimentado. Regenerando salud... (Salud: ", Global.salud_actual, "/100)")
		else:
			print("Hambre: ", Global.hambre_actual, "/100")
			
	else:
		Global.salud_actual -= daño_inanicion
		print("¡Estás muriendo de hambre! Salud: ", Global.salud_actual, "/100")

	# 2. PROCESAR RADIACIÓN
	if Global.radiacion_actual < 100:
		Global.radiacion_actual += incremento_radiacion
		if Global.radiacion_actual > 100:
			Global.radiacion_actual = 100
		print("Radiación Ambiental: ", Global.radiacion_actual, "%")
	else:
		# Si la radiación llegó al tope, empieza a quemar la salud
		Global.salud_actual -= daño_radiacion
		print("¡Niveles de radiación críticos! Salud: ", Global.salud_actual, "/100")

	# 3. VERIFICAR ESTADO VITAL
	if Global.salud_actual <= 0:
		morir()

func intentar_comer():
	# [NUEVO] Solo bloqueamos si AMBAS cosas están al 100%
	if Global.hambre_actual >= 100 and Global.salud_actual >= 100:
		print("Estás totalmente lleno y curado. No necesitas comer.")
		return
		
	var indice_comida = -1
	
	for i in range(Global.inventario.size()):
		var item = Global.inventario[i]
		var nombre_item = ""
		
		# [FIX] Validación segura: Verifica si es String o Diccionario/Recurso
		if item is String:
			nombre_item = item
		else:
			nombre_item = item.get("nombre") if item.get("nombre") != null else item.get("Nombre")
		
		if nombre_item == "Manzana" or nombre_item == "Comida":
			indice_comida = i
			break
			
	if indice_comida != -1:
		Global.inventario.remove_at(indice_comida)
		
		#La comida te llena el hambre Y te cura vida directa
		Global.hambre_actual += 20.0 
		Global.salud_actual += 15.0 # Te cura 15 puntos de salud al instante
		
		# Evitamos pasarnos de 100
		if Global.hambre_actual > 100:
			Global.hambre_actual = 100.0
		if Global.salud_actual > 100:
			Global.salud_actual = 100.0
			
		print("¡Comiste una Manzana! Hambre: ", Global.hambre_actual, " | Salud: ", Global.salud_actual)
	else:
		print("No tienes comida en el inventario.")

func morir():
	print("HAS MUERTO.")
	set_physics_process(false) 
	
	# Detiene el temporizador para que la consola no siga imprimiendo daño
	timer_metabolismo.stop() 
	
	if mirando_derecha:
		$AnimatedSprite2D.play("idle derecha") 
	else:
		$AnimatedSprite2D.play("idle izquierda")
