extends Node

# Diccionario global para guardar los ítems indexados por su ID
var items: Dictionary = {}

func _ready() -> void:
	# Busca en la carpeta exacta de tu proyecto
	load_items_from_directory("res://data/Items/recursos/")

func load_items_from_directory(path: String) -> void:
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var item = load(path + file_name) as ItemData
				if item:
					# Si el ítem no tiene ID, usa el nombre del archivo para no ignorarlo
					var clave = item.id if item.id != "" else file_name.get_basename()
					items[clave] = item
			file_name = dir.get_next()
		dir.list_dir_end()
	print("Base de datos de ítems cargada. Total: ", items.size())

func get_item(id: String) -> ItemData:
	if items.has(id):
		return items[id]
	return null
