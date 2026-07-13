extends Area2D

@export var escena_item_drop: PackedScene
@export var datos_comida: Resource 
@export var datos_rama: Resource #Palo 

var jugador_cerca: bool = false
var boost_activo: bool = false
var impactos_rama: int = 0
var ramas_disponibles: bool = true

# Tiempos de configuración en segundos
var tiempo_normal: float = 10.0
var tiempo_boost: float = 2.0
var duracion_boost: float = 12.0
var tiempo_regeneracion_ramas: float = 30.0 # Segundos para que el árbol vuelva a dar ramas

@onready var timer_drop = $TimerDrop
@onready var timer_boost = $TimerBoost
var timer_ramas: Timer # Cronómetro para las ramas creado por código

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	timer_drop.timeout.connect(_on_timer_drop_timeout)
	timer_boost.timeout.connect(_on_timer_boost_timeout)
	
	timer_drop.wait_time = tiempo_normal
	timer_drop.start()
	
	# Configuramos el temporizador oculto de las ramas
	timer_ramas = Timer.new()
	timer_ramas.one_shot = true
	timer_ramas.timeout.connect(_regenerar_ramas)
	add_child(timer_ramas)

func _on_body_entered(body):
	if body.name == "Player":
		jugador_cerca = true
		_mostrar_estado()

func _on_body_exited(body):
	if body.name == "Player":
		jugador_cerca = false

func _process(_delta):
	# Si presiona E, dejamos que el árbol decida qué hacer
	if jugador_cerca and Input.is_action_just_pressed("interact"):
		_interactuar()

func _interactuar():
	# 1. Revisamos si el jugador trae "Abono" en la mochila de forma segura
	var indice_abono = -1
	for i in range(Global.inventario.size()):
		var item = Global.inventario[i]
		var nombre_item = ""
		
		# Validación segura para evitar el error 'get on String'
		if item is String:
			nombre_item = item
		else:
			nombre_item = item.get("nombre") if item.get("nombre") != null else item.get("Nombre")
			
		if nombre_item == "Abono":
			indice_abono = i
			break
			
	# 2. LÓGICA DE PRIORIDAD:
	# Si tiene abono y el árbol no está potenciado -> Prioriza abonar el árbol
	if indice_abono != -1 and not boost_activo:
		aplicar_agua_y_abono(indice_abono)
		
	# Si NO tiene abono (o si ya está abonado), intentamos sacarle ramas
	elif ramas_disponibles:
		picar_ramas()
		
	else:
		print("El árbol no tiene más ramas por ahora y no tienes abono.")

# MECÁNICA DE RAMAS (CONSTRUCCIÓN DE ANTENA)
func picar_ramas():
	impactos_rama += 1
	print("¡Sacudiendo el árbol! (" + str(impactos_rama) + "/3)")
	
	if impactos_rama >= 3:
		print("¡Cayó una rama! El árbol necesita descansar para producir más madera.")
		ramas_disponibles = false
		impactos_rama = 0
		
		# Instanciamos físicamente la rama
		if escena_item_drop and datos_rama:
			var nuevo_item = escena_item_drop.instantiate()
			nuevo_item.datos_del_item = datos_rama
			# La rama cae un poco a la derecha (30 px) para no encimarse con las manzanas
			nuevo_item.global_position = global_position + Vector2(30, -30)
			get_tree().current_scene.add_child(nuevo_item)
		else:
			push_warning("ADVERTENCIA: Falta asignar 'Datos Rama' en el Inspector.")
			
		# Iniciamos el descanso del árbol
		timer_ramas.start(tiempo_regeneracion_ramas)

func _regenerar_ramas():
	ramas_disponibles = true
	print("El árbol ha vuelto a crecer sus ramas.")
	if jugador_cerca:
		_mostrar_estado()

# MECÁNICA DE COMIDA (SUPERVIVENCIA)
func _on_timer_drop_timeout():
	soltar_comida()

func soltar_comida():
	print("¡El árbol produjo comida!")
	if escena_item_drop and datos_comida:
		var nuevo_item = escena_item_drop.instantiate()
		nuevo_item.datos_del_item = datos_comida
		nuevo_item.global_position = global_position + Vector2(0, -50)
		get_tree().current_scene.add_child(nuevo_item)
		Global.guardar_juego()

func aplicar_agua_y_abono(indice_abono: int):
	boost_activo = true
	print("¡Árbol abonado! Producción acelerada.")
	
	# Eliminamos el abono del inventario (lo gastamos)
	Global.inventario.remove_at(indice_abono)
	
	# Aceleramos la caída de manzanas
	timer_drop.wait_time = tiempo_boost
	timer_drop.start()
	
	timer_boost.wait_time = duracion_boost
	timer_boost.one_shot = true
	timer_boost.start()

func _on_timer_boost_timeout():
	print("El efecto del abono ha terminado. Producción volviendo a la normalidad.")
	boost_activo = false
	timer_drop.wait_time = tiempo_normal
	timer_drop.start()

func _mostrar_estado():
	if ramas_disponibles and not boost_activo:
		print("Presiona E para sacar ramas o usar Abono si tienes.")
	elif not ramas_disponibles and not boost_activo:
		print("Presiona E para usar Abono (Ramas agotadas temporalmente).")
	elif ramas_disponibles and boost_activo:
		print("Presiona E para sacar ramas (Árbol ya abonado).")
