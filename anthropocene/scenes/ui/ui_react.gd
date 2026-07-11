extends Control

# Apunta al nodo WebView
@onready var web_view = $WebView 

func _ready() -> void:
	print("[GODOT] WebView inicializado apuntando a Vite: ", web_view.url)
