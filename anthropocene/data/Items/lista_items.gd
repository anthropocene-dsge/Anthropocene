@tool # Permite que el script ejecute código dentro del editor de Godot
class_name ListaItemsMaster
extends Resource

@export var lista_de_items: Array[ItemData] = []

<<<<<<< HEAD
# Creamos una variable booleana que actúa como un botón en el Inspector
=======
# Variable booleana que actúa como un botón en el Inspector
>>>>>>> 45ead31 (Actualizacion de inventario y nuevo item abono)
@export var ACTUALIZAR_LISTA_AUTOMATICAMENTE: bool = false:
	set(valor):
		if valor == true:
			_actualizar_lista_desde_carpeta()

func _actualizar_lista_desde_carpeta() -> void:
	var ruta_recursos = "res://data/Items/recursos/"
	var nuevos_items: Array[ItemData] = []
	
	var dir = DirAccess.open(ruta_recursos)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			# Buscamos solo los archivos de recursos (.tres)
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var item = load(ruta_recursos + file_name) as ItemData
				if item and not nuevos_items.has(item):
					nuevos_items.append(item)
			file_name = dir.get_next()
		dir.list_dir_end()
		
		lista_de_items = nuevos_items
		print("¡Lista actualizada! Se encontraron ", lista_de_items.size(), " ítems.")
<<<<<<< HEAD
=======
		# Fuerza al Inspector a refrescarse visualmente para ver los cambios
		notify_property_list_changed()
>>>>>>> 45ead31 (Actualizacion de inventario y nuevo item abono)
	else:
		print("Error: No se pudo abrir la carpeta en ", ruta_recursos)
