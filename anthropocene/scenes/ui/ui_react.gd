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

# ========================================================
# ENRUTADOR DE MENSAJES
# ========================================================
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

# ========================================================
# PROCESADORES DE ACCIONES (Handlers)
# ========================================================
func _process_login(payload: Dictionary) -> void:
	var username = payload.get("username", "")
	var password = payload.get("password", "")
	
	print("[IPC] Procesando Login para: ", username)
	
	# Si escribes 'sobreviviente' y 'anthropocene', dará acceso.
	var es_valido = (username == "sobreviviente" and password == "anthropocene")
	
	if es_valido:
		# 🛠️ DESACTIVADO TEMPORALMENTE: Comentamos esto para evitar el crash 
		# hasta que tu compañero configure su Global.gd
		# Global.usuario_logueado = username
		# Global.esta_autenticado = true
		print("[SESSION] Credenciales correctas. (Guardado en Global omitido por simulación)")
	else:
		print("[SESSION] Credenciales incorrectas.")
		
	# Enviar la respuesta obligatoria de vuelta a React
	var respuesta = {
		"type": "LOGIN_RESPONSE",
		"payload": { "success": es_valido }
	}
	_responder_a_react(respuesta)

#func _process_get_save_data() -> void:
	#print("[IPC] React solicita datos de guardado...")
	#
	## 🛠️ SIMULACIÓN TEMPORAL: fingimos que hay una partida guardada 
	## para verificar que React la reciba y pinte el botón de "Continuar"
	#var datos_simulados = {
		#"location": "SECTOR ALFA - BUNKER DE ATERRIZAJE",
		#"date": "11/07/2026",
		#"time": "17:00",
		#"playtime": "2h 15m",
		#"progress": 35
	#}
	#
	#var respuesta = {
		#"type": "SAVE_DATA_RESPONSE",
		#"payload": datos_simulados # Cambia a 'null' si quieres probar el estado vacío
	#}
	#_responder_a_react(respuesta)
func _process_get_save_data() -> void:
	print("[IPC] React solicita datos de guardado... Simulando disco vacío.")
	
	var respuesta = {
		"type": "SAVE_DATA_RESPONSE",
		"payload": null # <--- Al mandar null, le decimos a React que no hay nada
	}
	_responder_a_react(respuesta)

func _process_continue() -> void:
	print("[IPC ACTION] Continuando partida... Cambiando de escena.")
	
	# Inyectamos los datos en el Autoload antes de destruir el WebView
	Global.datos_partida_actual = {
		"location": "SECTOR ALFA - BUNKER DE ATERRIZAJE",
		"progress": 35
	}
	
	# Espera una fracción de segundo para dar espacio a las animaciones de React
	await get_tree().create_timer(0.4).timeout
	# Transición nativa de Godot
	get_tree().change_scene_to_file("res://scenes/MundoJugable.tscn")

func _process_new_game() -> void:
	print("[IPC ACTION] Iniciando nueva partida... Cambiando de escena.")
	
	Global.datos_partida_actual = {
		"location": "SECTOR ALFA - BUNKER DE ATERRIZAJE",
		"progress": 0
	}
	
	await get_tree().create_timer(0.4).timeout
	get_tree().change_scene_to_file("res://scenes/IntroJuego.tscn")


# ========================================================
# FUNCIÓN DE SALIDA (PUENTE DE REGRESO DEFINITIVO)
# ========================================================
func _responder_a_react(data_dict: Dictionary) -> void:
	var json_string = JSON.stringify(data_dict)
	
	# Construimos la línea de código JS usando comillas simples para el string de datos
	var script = "if (window.recibirMensajeDesdeGodot) { window.recibirMensajeDesdeGodot('" + json_string + "'); }"
	
	# Usamos el método nativo correcto: eval()
	web_view.eval(script)
	print("[IPC] Respuesta inyectada en la interfaz: ", data_dict.get("type"))
