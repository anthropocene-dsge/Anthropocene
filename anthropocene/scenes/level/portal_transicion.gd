extends Area2D

@export var archivo_siguiente_nivel: String
# En lugar de un checkbox, ahora escribes la coordenada X exacta a la que quieres llegar
@export var coordenada_X_destino: float = 100.0 

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		if archivo_siguiente_nivel != "":
			var altura_actual = body.global_position.y
			
			# Manda al jugador a la X exacta que elegiste en el inspector, 
			# conservando la altura Y por la que entró.
			Global.posicion_jugador_al_entrar = Vector2(coordenada_X_destino, altura_actual)
				
			# Usamos call_deferred para evitar el error rojo de las físicas
			get_tree().call_deferred("change_scene_to_file", archivo_siguiente_nivel)
		else:
			print("Error: No le asignaste un nivel a este portal")
