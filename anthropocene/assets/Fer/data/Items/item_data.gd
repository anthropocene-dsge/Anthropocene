# Es una lista generica, para que puedan agregar los items de cualquier tipo, salu2
class_name ItemData
extends Resource

# Enumerador simplificado solo con las categorías necesarias
enum ItemType { CONSUMIBLE, ARMA, MATERIAL }

@export_group("Identidad")
@export var id: String = ""
@export var nombre: String = ""
@export_multiline var descripcion: String = ""
@export var icono: Texture2D

@export_group("Propiedades")
@export var tipo: ItemType = ItemType.CONSUMIBLE
@export var valor_oro: int = 0
@export var es_acumulable: bool = true
@export var max_acumulacion: int = 32

@export_group("Datos de Gameplay (Genéricos)")
@export var estadisticas_personalizadas: Dictionary = {}
