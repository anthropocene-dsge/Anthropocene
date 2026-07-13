extends Control

# Apunta exactamente al nombre de tu nodo en la escena (GridContainer)
@onready var contenedor: GridContainer = $Contenedor_item

# --- RUTA DE TU TEXTURA DE HIERRO OXIDADO ---
# Reemplaza esta ruta por la ruta real de tu imagen en el Sistema de Archivos
const TEXTURA_METAL = preload("res://assets/suelo.png") 

func _ready() -> void:
	print("--- INICIALIZANDO INTERFAZ DE INVENTARIO ---")
	await get_tree().process_frame
	await get_tree().process_frame
	dibujar_inventario()

func dibujar_inventario() -> void:
	if not contenedor:
		print("CRÍTICO: No se encontró el nodo '$Contenedor_item'")
		return

	for hijo in contenedor.get_children():
		hijo.queue_free()
	
	var base_datos = get_node_or_null("/root/ItemDatabase")
	if not base_datos:
		print("CRÍTICO: El Autoload 'ItemDatabase' no está activo o configurado en el proyecto.")
		return
		
	print("Cantidad de ítems encontrados en la BD al dibujar: ", base_datos.items.size())

	if base_datos.items.size() == 0:
		print("Advertencia: La base de datos cargó, pero hay 0 ítems en 'data/Items/recursos/'.")
		return

	# --- CONFIGURACIÓN DEL ESTILO DE HIERRO OXIDADO (9-SLICE) ---
	var estilo_metal = StyleBoxTexture.new()
	estilo_metal.texture = TEXTURA_METAL
	
	# Ajusta estos márgenes (en píxeles) para que las esquinas de tu metal no se estiren feo.
	# Si tu textura tiene un borde de 4 píxeles, ponle 4 a todo.
	estilo_metal.texture_margin_left = 6.0
	estilo_metal.texture_margin_right = 6.0
	estilo_metal.texture_margin_top = 6.0
	estilo_metal.texture_margin_bottom = 6.0

	# Dibujamos un botón por cada ítem
	for item_id in base_datos.items:
		var datos_item: ItemData = base_datos.items[item_id]
		print("Dibujando ítem visual: ", datos_item.nombre)
		
		var boton_item = Button.new()
		boton_item.text = datos_item.nombre if datos_item.nombre != "" else item_id
		boton_item.icon = datos_item.icono
		boton_item.expand_icon = true
		
		# Tamaño explícito
		boton_item.custom_minimum_size = Vector2(120, 100)
		
		# --- INYECTAR LA TEXTURA DE HIERRO AL BOTÓN ---
		# Aplicamos el estilo de metal para cuando el botón está normal, presionado o con el mouse encima
		boton_item.add_theme_stylebox_override("normal", estilo_metal)
		boton_item.add_theme_stylebox_override("hover", estilo_metal)
		boton_item.add_theme_stylebox_override("pressed", estilo_metal)
		boton_item.add_theme_stylebox_override("focus", StyleBoxEmpty.new()) # Quita el molesto marco de enfoque
		
		# Ajustar márgenes internos para que el texto e icono no toquen el borde del metal
		boton_item.add_theme_constant_override("outline_size", 0) # Estilo limpio
		
		# Configuración del Tooltip
		var nombre_tipo: String = "Desconocido"
		if datos_item.tipo == ItemData.ItemType.CONSUMIBLE:
			nombre_tipo = "Consumible"
		elif datos_item.tipo == ItemData.ItemType.ARMA:
			nombre_tipo = "Arma"
		elif datos_item.tipo == ItemData.ItemType.MATERIAL:
			nombre_tipo = "Material"
		
		boton_item.tooltip_text = "Tipo: %s\nValor: %d oro\n%s" % [
			nombre_tipo, 
			datos_item.valor_oro, 
			datos_item.descripcion
		]
		
		contenedor.add_child(boton_item)
	
	contenedor.queue_redraw()
