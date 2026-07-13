class_name HUDJugador
extends Control

# Enlaces directos a los componentes
@onready var barra_vida: TextureProgressBar = $MarginContainer/HBoxContainer/VBoxContainer/BarraVida
@onready var barra_radiacion: TextureProgressBar = $MarginContainer/HBoxContainer/VBoxContainer/BarraRadiacion
@onready var icono_item: TextureRect = $MarginContainer/HBoxContainer/PanelContainer/TextureRect
@onready var mensaje_interaccion: Label = $Label

# --- RUTAS DE SPRITES (Ajusta los nombres exactos de tus archivos) ---
# Copia los nombres reales de tus archivos dentro de assets/extras/
const VIDA_VERDE = preload("res://assets/extras/vida_verde.png")
const VIDA_AMARILLA = preload("res://assets/extras/vida_amarilla.png")
const VIDA_ROJA = preload("res://assets/extras/vida_roja.png")

const RAD_VERDE = preload("res://assets/extras/rad_verde.png")
const RAD_AMARILLA = preload("res://assets/extras/rad_amarilla.png")
const RAD_ROJA = preload("res://assets/extras/rad_roja.png")

func _ready() -> void:
	# Simulación de prueba temporal al dar F6
	actualizar_vida(100.0, 100.0) # Cambia este 100 por 50 o 10 para probar los colores
	actualizar_radiacion(20.0, 100.0)

# --- MÓDULOS DE ACTUALIZACIÓN ---

func actualizar_vida(valor_actual: float, valor_maximo: float = 100.0) -> void:
	barra_vida.max_value = valor_maximo
	barra_vida.value = valor_actual
	
	# Calcular el porcentaje para decidir el sprite
	var porcentaje = (valor_actual / valor_maximo) * 100.0
	
	if porcentaje > 60.0:
		barra_vida.texture_progress = VIDA_VERDE
	elif porcentaje > 20.0:
		barra_vida.texture_progress = VIDA_AMARILLA
	else:
		barra_vida.texture_progress = VIDA_ROJA


func actualizar_radiacion(valor_actual: float, valor_maximo: float = 100.0) -> void:
	barra_radiacion.max_value = valor_maximo
	barra_radiacion.value = valor_actual
	
	var porcentaje = (valor_actual / valor_maximo) * 100.0
	
	# Nota: Si en tu diseño más radiación es más peligroso, puedes invertir la lógica.
	# Aquí asumimos: <30% limpia (Verde), 30%-70% alerta (Amarilla), >70% crítica (Roja)
	if porcentaje < 30.0:
		barra_radiacion.texture_progress = RAD_VERDE
	elif porcentaje < 70.0:
		barra_radiacion.texture_progress = RAD_AMARILLA
	else:
		barra_radiacion.texture_progress = RAD_ROJA


func actualizar_item_mano(textura_item: Texture2D) -> void:
	if textura_item:
		icono_item.texture = textura_item
		icono_item.visible = true
	else:
		icono_item.texture = null
		icono_item.visible = false


func mostrar_aviso_interaccion(visible: bool, tecla: String = "E", accion: String = "Interactuar") -> void:
	mensaje_interaccion.visible = visible
	if visible:
		mensaje_interaccion.text = "Presiona la tecla [%s] para %s" % [tecla.to_upper(), accion]
