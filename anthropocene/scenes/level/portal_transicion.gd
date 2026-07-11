extends Area2D

@export var archivo_siguiente_nivel: String
@export var aparecer_en_izquierda: bool = true

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.name == "Player":
		if archivo_siguiente_nivel != "":
			var limites = get_viewport_rect().size
			var altura_actual = body.global_position.y
			
			# Aumentamos este número para evitar aparecer tocando el portal
			var margen_seguro = 100 
			
			if aparecer_en_izquierda:
				# Aparece lejos del portal izquierdo
				Global.posicion_jugador_al_entrar = Vector2(margen_seguro, altura_actual)
			else:
				# Aparece lejos del portal derecho
				Global.posicion_jugador_al_entrar = Vector2(limites.x - margen_seguro, altura_actual)
				
			# Usamos call_deferred para evitar el error rojo de las físicas
			get_tree().call_deferred("change_scene_to_file", archivo_siguiente_nivel)
		else:
			print("Error: No le asignaste un nivel a este portal")
