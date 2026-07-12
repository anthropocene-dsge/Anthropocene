extends Control

@onready var web_view = $WebView 

func _ready() -> void:
	var ruta_absoluta = ProjectSettings.globalize_path("res://ui_bundle/index.html")
	web_view.url = "file://" + ruta_absoluta
	print("[GODOT] Cargando interfaz desde: ", web_view.url)

	if web_view.has_signal("ipc_message"):
		web_view.ipc_message.connect(_on_message_from_react)
		print("[IPC] Conexión establecida de forma segura. Escuchando a React...")
	else:
		push_error("CRÍTICO: No se pudo conectar la señal ipc_message.")

# ENRUTADOR DE MENSAJES
func _on_message_from_react(message_str: String) -> void:
	var json = JSON.new()
	if json.parse(message_str) != OK:
		push_error("[IPC] Error al parsear JSON desde React: " + message_str)
		return
		
	var msg = json.get_data()
	var type = msg.get("type", "")
	var payload = msg.get("payload", null)
	
	match type:
		"LOGIN_REQUEST":
			_process_login(payload)
		"GET_SAVE_DATA":
			_process_get_save_data()
		"CONTINUE_GAME":
			_process_continue()
		"NEW_GAME":
			_process_new_game()
		_:
			print("[IPC WARN] Evento no manejado aún: ", type)

# PROCESADORES DE ACCIONES REALES
func _process_login(payload: Dictionary) -> void:
	var username = payload.get("username", "")
	var password = payload.get("password", "")
	
	print("[IPC] Procesando Login en base de datos local para: ", username)
	
	var es_valido = FileStorage.verificar_credenciales(username, password)
	
	if es_valido:
		# Activamos la sesión oficial en la memoria del juego
		Global.usuario_logueado = username
		Global.esta_autenticado = true
		print("[SESSION] Credenciales correctas. Registrado en Global.")
	else:
		print("[SESSION] Credenciales incorrectas o inexistentes.")
		
	# Enviar la respuesta a React
	var respuesta = {
		"type": "LOGIN_RESPONSE",
		"payload": { "success": es_valido }
	}
	_responder_a_react(respuesta)

func _process_get_save_data() -> void:
	print("[IPC] React solicita datos de guardado... Buscando en disco.")
	
	var datos_reales = FileStorage.cargar_progreso()
	
	var respuesta = {
		"type": "SAVE_DATA_RESPONSE",
		"payload": null
	}
	
	if datos_reales.is_empty():
		print("[IPC] Disco local vacío. No hay partidas registradas.")
	else:
		respuesta["payload"] = datos_reales
		Global.datos_partida_actual = datos_reales
		print("[IPC] Datos de partida reales cargados y enviados a React.")
		
	_responder_a_react(respuesta)

func _process_continue() -> void:
	print("[IPC ACTION] Continuando partida real... Desplegando mundo.")
	
	# No hace falta reescribir los datos de Global, ya se cargaron en _process_get_save_data()
	# Solo damos margen para la animación y transicionamos.
	await get_tree().create_timer(0.4).timeout
	get_tree().change_scene_to_file("res://scenes/MundoJugable.tscn")

func _process_new_game() -> void:
	print("[IPC ACTION] Iniciando nueva partida... Sobreescribiendo sector local.")
	
	# Construimos la base de datos de inicio para el colono
	var nuevos_datos = {
		"location": "SECTOR 00 - El COMIENZO... de nuevo.",
		"date": Time.get_date_string_from_system(),
		"time": Time.get_time_string_from_system().substr(0, 5),
		"playtime": "0h 0m",
		"progress": 0
	}
	
	# Guardamos de forma real en el disco y seteamos la variable global
	FileStorage.guardar_progreso(nuevos_datos)
	Global.datos_partida_actual = nuevos_datos
	
	await get_tree().create_timer(0.4).timeout
	get_tree().change_scene_to_file("res://scenes/IntroJuego.tscn")

# FUNCIÓN DE SALIDA (PUENTE DE REGRESO DEFINITIVO)
func _responder_a_react(data_dict: Dictionary) -> void:
	var json_string = JSON.stringify(data_dict)
	
	# Construimos la línea de código JS usando comillas simples para el string
	var script = "if (window.recibirMensajeDesdeGodot) { window.recibirMensajeDesdeGodot('" + json_string + "'); }"
	
	# Ejecutamos en el WebView
	web_view.eval(script)
	print("[IPC] Respuesta inyectada en la interfaz: ", data_dict.get("type"))
