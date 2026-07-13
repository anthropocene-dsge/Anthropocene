extends Area2D

# variables para el drop de el abono
@export var escena_item_drop: PackedScene
@export var datos_abono: Resource # Aquí irá abono.tres
var timer_produccion: Timer

@export var engranajes_necesarios: int = 3 
@export var tiempo_vida_engranajes: float = 120.0 

var jugador_cerca: bool = false
var turbina_activada: bool = false

var valor_viento: int = 0
var nivel_energia: String = "Ninguna"
var timer_clima: Timer
var timer_desgaste: Timer

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Configurar cronómetros
	timer_clima = Timer.new()
	timer_clima.wait_time = 5.0 
	timer_clima.timeout.connect(_actualizar_clima)
	add_child(timer_clima)
	
	timer_desgaste = Timer.new()
	timer_desgaste.one_shot = true
	timer_desgaste.timeout.connect(_romper_turbina)
	add_child(timer_desgaste)
	
	# Cronómetro para producir energía y abono cada 5 segundos
	timer_produccion = Timer.new()
	timer_produccion.wait_time = 5.0
	timer_produccion.timeout.connect(_ciclo_de_produccion)
	add_child(timer_produccion)
	timer_produccion.start()
	
	# SISTEMA DE MEMORIA Y PRODUCCIÓN OFFLINE
	if Global.turbina_reparada:
		var tiempo_actual = Time.get_unix_time_from_system()
		
		# 1. CÁLCULO DE ENERGÍA PERDIDA
		if Global.turbina_ultima_vez > 0:
			var tiempo_ausente = tiempo_actual - Global.turbina_ultima_vez
			
			# Ojo: Si la turbina se rompió mientras estabas lejos, 
			# solo calculamos el tiempo que REALMENTE estuvo funcionando.
			if tiempo_actual > Global.turbina_tiempo_fin:
				tiempo_ausente = Global.turbina_tiempo_fin - Global.turbina_ultima_vez
				
			if tiempo_ausente > 0:
				# Calculamos cuántos ciclos de 5 segundos pasaron
				var ciclos_perdidos = int(tiempo_ausente / 5.0) 
				
				if ciclos_perdidos > 0:
					# Le damos un promedio de 15 de energía por ciclo perdido
					var energia_recuperada = ciclos_perdidos * 15 
					Global.energia_acumulada += energia_recuperada
					print("[SISTEMA] Producción Offline: La turbina generó ", energia_recuperada, " de energía mientras no estabas.")
		
		# 2. VERIFICACIÓN DE DESGASTE FÍSICO
		if tiempo_actual < Global.turbina_tiempo_fin:
			turbina_activada = true
			var tiempo_sobrante = Global.turbina_tiempo_fin - tiempo_actual
			timer_desgaste.start(tiempo_sobrante)
			print("[SISTEMA] Turbina recuperada. Tiempo de vida restante: ", int(tiempo_sobrante), "s")
		else:
			print("[SISTEMA] Los engranajes se rompieron mientras estabas lejos.")
			turbina_activada = false
			Global.turbina_reparada = false

func _on_body_entered(body):
	if body.name == "Player":
		jugador_cerca = true
		_mostrar_info_consola()

func _on_body_exited(body):
	if body.name == "Player":
		jugador_cerca = false

func _process(_delta):
	if jugador_cerca and Input.is_action_just_pressed("interact") and not turbina_activada:
		intentar_reparar()

func intentar_reparar():
	var indices_engranajes = []
	
	for i in range(Global.inventario.size()):
		var item = Global.inventario[i]
		var nombre_item = ""
		
		# Validación segura para evitar el error 'get on String'
		if item is String:
			nombre_item = item
		else:
			nombre_item = item.get("nombre") if item.get("nombre") != null else item.get("Nombre")
			
		if nombre_item == "Engranaje":
			indices_engranajes.append(i)
			
	if indices_engranajes.size() >= engranajes_necesarios:
		print("¡Turbina reparada! Has usado ", engranajes_necesarios, " engranajes de piedra.")
		turbina_activada = true
		
		indices_engranajes.reverse()
		for i in range(engranajes_necesarios):
			Global.inventario.remove_at(indices_engranajes[i])
			
		timer_desgaste.start(tiempo_vida_engranajes)
		
		# GUARDAMOS EL ESTADO EN LA MEMORIA GLOBAL
		Global.turbina_reparada = true
		# Guardamos la hora exacta actual + los 120 segundos que le dimos de vida
		Global.turbina_tiempo_fin = Time.get_unix_time_from_system() + tiempo_vida_engranajes
		
		_aplicar_efecto_energia()
		
	else:
		print("Faltan piezas. Tienes ", indices_engranajes.size(), "/", engranajes_necesarios, " Engranajes.")

func _romper_turbina():
	print("¡CRACK! Los engranajes de piedra se pulverizaron.")
	turbina_activada = false
	
	# Borramos el registro en la memoria global
	Global.turbina_reparada = false 
	
	$AnimatedSprite2D.play("idle")
	if jugador_cerca:
		_mostrar_info_consola()

# MOTOR CLIMÁTICO Y VISUAL
func _actualizar_clima():
	valor_viento = randi_range(0, 15)
	
	if valor_viento == 0:
		nivel_energia = "Ninguna"
	elif valor_viento > 0 and valor_viento < 5:
		nivel_energia = "Mínima (Insuficiente)"
	elif valor_viento >= 5 and valor_viento <= 10:
		nivel_energia = "Moderada"
	elif valor_viento > 10:
		nivel_energia = "Alta"
		
	if turbina_activada:
		_aplicar_efecto_energia()

func _aplicar_efecto_energia():
	if not turbina_activada:
		$AnimatedSprite2D.play("idle")
		return
		
	match nivel_energia:
		"Ninguna", "Mínima (Insuficiente)":
			$AnimatedSprite2D.play("idle")
			print("[ENERGÍA] Turbina lista, pero el viento es muy débil (", valor_viento, "/15)")
		"Moderada":
			$AnimatedSprite2D.play("wind_low")
			print("[ENERGÍA] Producción Moderada. (", valor_viento, "/15)")
		"Alta":
			$AnimatedSprite2D.play("wind_high")
			print("[ENERGÍA] ¡Producción Alta! (", valor_viento, "/15)")

func _mostrar_info_consola():
	if not turbina_activada:
		print("Turbina Rota. Requiere ", engranajes_necesarios, " Engranajes. (Viento: ", valor_viento, ")")
	else:
		print("Turbina Operativa. Viento: ", valor_viento, " | Tiempo de vida restante: ", int(timer_desgaste.time_left), "s")

# SISTEMA DE PRODUCCIÓN (RECURSOS Y ENERGÍA)
func _ciclo_de_produccion():
	if not turbina_activada:
		return # Si está rota, no produce nada
		
	var energia_generada = 0
	var cantidad_abono = 0
	
	match nivel_energia:
		"Mínima (Insuficiente)", "Ninguna":
			energia_generada = 0
		"Moderada":
			energia_generada = 10
			cantidad_abono = 1
		"Alta":
			energia_generada = 30
			cantidad_abono = 3 
			
	# Sumamos a la batería global
	Global.energia_acumulada += energia_generada
	
	if energia_generada > 0:
		print("⚡ Energía Total Acumulada: ", Global.energia_acumulada)
		
	# Instanciamos los sacos de abono físicamente
	if cantidad_abono > 0 and escena_item_drop and datos_abono:
		for i in range(cantidad_abono):
			var nuevo_item = escena_item_drop.instantiate()
			nuevo_item.datos_del_item = datos_abono
			
			# Hacemos que caigan un poco separados entre sí
			var offset_x = randi_range(-50, 50)
			nuevo_item.global_position = global_position + Vector2(offset_x, -20)
			get_tree().current_scene.add_child(nuevo_item)

func _exit_tree():
	# Si nos vamos del mapa y la turbina estaba prendida, anotamos la hora
	if turbina_activada:
		Global.turbina_ultima_vez = Time.get_unix_time_from_system()
