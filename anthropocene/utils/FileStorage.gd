class_name FileStorage

const AUTH_FILE_PATH = "user://auth_data.json"
const SAVE_FILE_PATH = "user://save_data.json"

static func asegurar_archivos_base() -> void:
	if not FileAccess.file_exists(AUTH_FILE_PATH):
		var default_auth = {
			"users": [
				{ "username": "sobreviviente", "password": "anthropocene" }
			]
		}
		var file = FileAccess.open(AUTH_FILE_PATH, FileAccess.WRITE)
		if file:
			file.store_string(JSON.stringify(default_auth))
			file.close()
			print("[STORAGE] Inicializado archivo de autenticación base.")

static func verificar_credenciales(user: String, password: String) -> bool:
	asegurar_archivos_base() # cite: 2
	var file = FileAccess.open(AUTH_FILE_PATH, FileAccess.READ) # cite: 2
	if not file:
		return false # cite: 2
	var text = file.get_as_text()
	file.close() # cite: 2
	var data = JSON.parse_string(text)
	if data and data.has("users") and data["users"] is Array: # cite: 2
		for u in data["users"]: # cite: 2
			if u.get("username", "") == user and u.get("password", "") == password:
				return true 
	return false

static func cargar_progreso() -> Dictionary:
	if not FileAccess.file_exists(SAVE_FILE_PATH): 
		return {}  
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)  
	if not file:
		return {}  
	var text = file.get_as_text()
	file.close()  
	var data = JSON.parse_string(text)
	if data is Dictionary:  
		return data  
	return {}  

static func guardar_progreso(nuevos_datos: Dictionary) -> void:
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)  
	if file:
		file.store_string(JSON.stringify(nuevos_datos))  
		file.close()  
		print("[STORAGE] Progreso del colono persistido en disco duro.") 