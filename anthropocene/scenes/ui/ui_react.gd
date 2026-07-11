extends Control

@onready var web_view = $WebView 

func _ready() -> void:
	var ruta_absoluta = ProjectSettings.globalize_path("res://ui_bundle/index.html")
	
	# Le indicamos al WebView que abra el archivo local
	web_view.url = "file://" + ruta_absoluta
	print("[GODOT] Cargando interfaz desde: ", web_view.url)
