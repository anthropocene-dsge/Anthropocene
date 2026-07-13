extends CharacterBody2D

@export var datos_del_item: Resource

# Obtenemos la gravedad global del proyecto
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	# Asignamos el dibujo original
	if datos_del_item != null:
		if datos_del_item.get("Icono") != null:
			$Sprite2D.texture = datos_del_item.get("Icono")
			
	# Efecto de "botar": Impulso aleatorio hacia los lados y hacia arriba
	velocity = Vector2(randf_range(-120, 120), -300)
	
	# Conectamos la zona de recolección
	$ZonaRecoleccion.body_entered.connect(_on_zona_recoleccion_body_entered)

func _physics_process(delta):
	# Si no está tocando el piso (TileMap), le aplicamos gravedad
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		# Si ya tocó el piso, aplicamos fricción para que deje de resbalar
		velocity.x = move_toward(velocity.x, 0, 15) 
		
	# Comando nativo para aplicar el movimiento y chocar
	move_and_slide()

func _on_zona_recoleccion_body_entered(body):
	if body.name == "Player":
		var nombre_item = "Objeto desconocido"
		
		# Revisamos la variable ("nombre" en minúscula o mayúscula)
		if datos_del_item != null:
			nombre_item = datos_del_item.get("nombre") if datos_del_item.get("nombre") != null else datos_del_item.get("Nombre")
			
		print("¡Recogiste: " + nombre_item + "!")
		
		# [REPARACIÓN DEFINITIVA] Creamos un diccionario limpio para el inventario
		var nuevo_item_para_guardar = {
			"nombre": nombre_item
		}
		
		# Guardamos el diccionario, NO el recurso
		Global.inventario.append(nuevo_item_para_guardar)
		print("Inventario actual: ", Global.inventario.size(), " objetos")
		
		queue_free()
