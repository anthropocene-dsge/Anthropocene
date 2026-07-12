extends Node
var esta_autenticado: bool = false
var datos_partida_actual: Dictionary = {}
var posicion_jugador_al_entrar: Vector2 = Vector2.ZERO

# VARIABLES JUGADOR
var salud_actual: float = 100.0
var hambre_actual: float = 100.0
var radiacion_actual: float = 0.0 # Empieza limpio, en 0%

# VARIABLES DEL JUEGO
var inventario: Array = []
var energia_acumulada: float = 0.0

# VARIABLES ESTRUCTURAS
var turbina_reparada: bool = false
var turbina_tiempo_fin: float = 0.0 
var turbina_ultima_vez: float = 0.0

# RUTA DEL ARCHIVO DE GUARDADO
const RUTA_GUARDADO = "user://partida_supervivencia.json"

func _ready():
	# Al abrir el juego, cargamos la partida automáticamente
	cargar_juego()
	# Cronómetro de autoguardado (cada 60 segundos)
	var timer_auto = Timer.new()
	timer_auto.wait_time = 60.0
	if Global.salud_actual > 0:
		timer_auto.timeout.connect(guardar_juego)
	add_child(timer_auto)
	timer_auto.start()

# SOLUCIÓN AL PITIDO DE WINDOWS
func _unhandled_key_input(event):
	if event.pressed:
		# Si la tecla no fue usada por un botón de la interfaz, 
		# la marcamos como "manejada" para que Windows no chille.
		get_viewport().set_input_as_handled()

# SISTEMA DE GUARDADO Y CARGA
func guardar_juego():
	var datos = {
		"inventario": inventario,
		"energia_acumulada": energia_acumulada,
		"turbina_reparada": turbina_reparada,
		"turbina_ultima_vez": Time.get_unix_time_from_system(),
		"turbina_tiempo_fin": turbina_tiempo_fin,
		# Añadimos las estadísticas al diccionario JSON
		"salud_actual": salud_actual,
		"hambre_actual": hambre_actual,
		"radiacion_actual": radiacion_actual
	}
	
	# 2. Abrimos el archivo en modo ESCRITURA
	var archivo = FileAccess.open(RUTA_GUARDADO, FileAccess.WRITE)
	if archivo:
		# Convertimos el diccionario a un texto JSON ordenado
		var json_string = JSON.stringify(datos, "\t")
		archivo.store_string(json_string)
		archivo.close()
		print("[SISTEMA] Partida guardada correctamente en: ", RUTA_GUARDADO)
	else:
		print("[SISTEMA] Error al intentar guardar la partida.")

func cargar_juego():
	# 1. Verificamos si el archivo de guardado existe
	if not FileAccess.file_exists(RUTA_GUARDADO):
		print("[SISTEMA] No hay partida guardada. Iniciando un juego nuevo.")
		return
		
	# 2. Abrimos el archivo en modo LECTURA
	var archivo = FileAccess.open(RUTA_GUARDADO, FileAccess.READ)
	if archivo:
		var json_string = archivo.get_as_text()
		archivo.close()
		
		# 3. Convertimos el texto JSON de vuelta a datos de Godot
		var datos = JSON.parse_string(json_string)
		
		if datos: # Si no hubo error al decodificar
			inventario = datos.get("inventario", [])
			energia_acumulada = datos.get("energia_acumulada", 0.0)
			turbina_reparada = datos.get("turbina_reparada", false)
			turbina_tiempo_fin = datos.get("turbina_tiempo_fin", 0.0)
			turbina_ultima_vez = datos.get("turbina_ultima_vez", 0.0)
			salud_actual = datos.get("salud_actual", 100.0)
			hambre_actual = datos.get("hambre_actual", 100.0)
		if salud_actual <= 0:
			salud_actual = 50.0 # Te damos 50 de vida al revivir
			hambre_actual = 50.0
			print("[SISTEMA] Detección de muerte: Reviviendo jugador...")
