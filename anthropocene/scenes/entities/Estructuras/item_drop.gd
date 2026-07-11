extends CharacterBody2D

@export var datos_del_item: Resource

# Obtenemos la gravedad global del proyecto
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

func _ready():
	# Asignamos el dibujo de Uriel
	if datos_del_item != null:
		if datos_del_item.get("Icono") != null:
			$Sprite2D.texture = datos_del_item.get("Icono")
			
	# Efecto de "botar": Impulso aleatorio hacia los lados y hacia arriba
	velocity = Vector2(randf_range(-120, 120), -300)
	
	# Conectamos la nueva zona de recolección
	$ZonaRecoleccion.body_entered.connect(_on_zona_recoleccion_body_entered)

func _physics_process(delta):
	# Si no está tocando el TileMap, le aplicamos gravedad
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		# Si ya tocó el piso, aplicamos fricción para que deje de resbalar
		velocity.x = move_toward(velocity.x, 0, 15) 
		
	# Comando nativo para aplicar el movimiento y chocar
	move_and_slide()

func _on_zona_recoleccion_body_entered(body):
	# Al pasar encima, leemos el nombre y destruimos el ítem físico
	if body.name == "Player":
		var nombre_item = "Objeto desconocido"
		if datos_del_item != null and datos_del_item.get("Nombre") != null:
			nombre_item = datos_del_item.get("Nombre")
			
		print("¡Recogiste: " + nombre_item + "!")
		
		# (Aquí Jun conectará su lógica para guardarlo en Global.inventario)
		
		queue_free()
