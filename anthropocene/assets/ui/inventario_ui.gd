extends Control

# Apunta exactamente al nombre de tu nodo en la escena (GridContainer)
@onready var contenedor: GridContainer = $Contenedor_item

func _ready() -> void:
	# Imprime en la consola de Godot para confirmar que el script arrancó
	print("--- INICIALIZANDO INTERFAZ DE INVENTARIO ---")
	
	# Forzamos una espera de dos cuadros para garantizar que el motor 
	# haya instanciado y posicionado el GridContainer correctamente
	await get_tree().process_frame
	await get_tree().process_frame
	
	dibujar_inventario()

func dibujar_inventario() -> void:
	# Seguridad: Si por alguna razón el nodo no está conectado, frena el código
	if not contenedor:
		print("CRÍTICO: No se encontró el nodo '$Contenedor_item'")
		return

	# Limpiamos los botones viejos de la interfaz antes de redibujar
	for hijo in contenedor.get_children():
		hijo.queue_free()
	
	# Buscamos el Autoload global en el motor
	var base_datos = get_node_or_null("/root/ItemDatabase")
	if not base_datos:
		print("CRÍTICO: El Autoload 'ItemDatabase' no está activo o configurado en el proyecto.")
		return
		
	print("Cantidad de ítems encontrados en la BD al dibujar: ", base_datos.items.size())

	# Si la base de datos no ha leído nada, te avisa en la consola
	if base_datos.items.size() == 0:
		print("Advertencia: La base de datos cargó, pero hay 0 ítems en 'data/Items/recursos/'.")
		return

	# Dibujamos un botón por cada ítem que exista en el diccionario global
	for item_id in base_datos.items:
		var datos_item: ItemData = base_datos.items[item_id]
		print("Dibujando ítem visual: ", datos_item.nombre)
		
		var boton_item = Button.new()
		# Si el recurso no tiene nombre manual en el Inspector, usa su ID de archivo
		boton_item.text = datos_item.nombre if datos_item.nombre != "" else item_id
		boton_item.icon = datos_item.icono
		boton_item.expand_icon = true
		
		# Tamaño explícito para asegurar que el GridContainer no lo colapse a 0x0
		boton_item.custom_minimum_size = Vector2(100, 100)
		
		# Convertimos el número del enum de forma segura en Godot 4 a un texto legible
		var nombre_tipo: String = "Desconocido"
		if datos_item.tipo == ItemData.ItemType.CONSUMIBLE:
			nombre_tipo = "Consumible"
		elif datos_item.tipo == ItemData.ItemType.ARMA:
			nombre_tipo = "Arma"
		elif datos_item.tipo == ItemData.ItemType.MATERIAL:
			nombre_tipo = "Material"
		
		# Guardamos los datos para que aparezcan en el recuadro flotante (Tooltip) al pasar el mouse
		boton_item.tooltip_text = "Tipo: %s\nValor: %d oro\n%s" % [
			nombre_tipo, 
			datos_item.valor_oro, 
			datos_item.descripcion
		]
		
		# Añadimos el botón recién configurado dentro de la cuadrícula
		contenedor.add_child(boton_item)
	
	# Forzamos al contenedor a redibujar sus dimensiones internas inmediatamente
	contenedor.queue_redraw()
