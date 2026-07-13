extends Area2D

@export var ramas_necesarias: int = 15
@export var engranajes_necesarios: int = 5
@export var energia_necesaria: float = 1000.0

var jugador_cerca: bool = false
var juego_terminado: bool = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Verificación de seguridad para la animación
	if $AnimatedSprite2D.sprite_frames.has_animation("idle"):
		$AnimatedSprite2D.play("idle")
	else:
		print("ADVERTENCIA: La animación 'idle' no existe en el AnimatedSprite2D. Revisa el nombre en el editor.")

func _on_body_entered(body):
	if body.name == "Player":
		jugador_cerca = true
		if not juego_terminado:
			print("--- ANTENA DE TRANSMISIÓN ---")
			print("Presiona E para intentar iniciar la secuencia final.")

func _on_body_exited(body):
	if body.name == "Player":
		jugador_cerca = false

func _process(_delta):
	if jugador_cerca and Input.is_action_just_pressed("interact") and not juego_terminado:
		verificar_victoria()

func verificar_victoria():
	var total_ramas = 0
	var total_engranajes = 0
	
	for item in Global.inventario:
		var nombre_item = ""
		
		# Validación segura: comprobamos si el ítem es String o Diccionario
		if item is String:
			nombre_item = item
		else:
			nombre_item = item.get("nombre") if item.get("nombre") != null else item.get("Nombre")
			
		if nombre_item == "Rama" or nombre_item == "Palo" or nombre_item == "palo":
			total_ramas += 1
		elif nombre_item == "Engranaje":
			total_engranajes += 1
			
	print("\n[REQUISITOS DEL SISTEMA]")
	print("- Ramas estructurales: ", total_ramas, " / ", ramas_necesarias)
	print("- Engranajes mecánicos: ", total_engranajes, " / ", engranajes_necesarios)
	print("- Energía acumulada: ", Global.energia_acumulada, " / ", energia_necesaria)
	
	if total_ramas >= ramas_necesarias and total_engranajes >= engranajes_necesarios and Global.energia_acumulada >= energia_necesaria:
		ejecutar_final()
	else:
		print("Secuencia abortada. Faltan recursos.")

func ejecutar_final():
	juego_terminado = true
	
	print("\n[SISTEMA] Iniciando secuencia de transmisión...")
	
	# 1. Iniciamos la animación de funcionamiento
	# Asegúrate de que esta animación se llame "Funcionando" en el panel de animaciones
	if $AnimatedSprite2D.sprite_frames.has_animation("Funcionando"):
		$AnimatedSprite2D.play("Funcionando")
	
	# 2. Espera de la animación
	await get_tree().create_timer(20.0).timeout 
	
	# 3. Después de los 20 segundos, se ejecuta la victoria final
	print("\n================================================")
	print("¡ANTENA OPERATIVA! TRANSMISIÓN ENVIADA CON ÉXITO.")
	print("¡HAS LOGRADO RECONSTRUIR EL SISTEMA! ¡VICTORIA!")
	print("================================================")
	if Global.salud_actual > 0:
		Global.guardar_juego()
	
	# PANTALLA FINAL (Descomenta esta línea cuando tengas tu escena de victoria lista)
	# get_tree().change_scene_to_file("res://scenes/PantallaVictoria.tscn")
