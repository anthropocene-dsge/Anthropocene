extends Node2D

@onready var texto_label = $RichTextLabel
@onready var timer = $Timer
@onready var sonido_bip = $AudioStreamPlayer2D  # <- Asegúrate de que tenga el 2D aquí

# Escribe aquí tu propia historia entre las comillas
var historia = "El mundo no terminó con un susurro, sino con el rugido ensordecedor de mil soles artificiales. Décadas de tensión nuclear devoraron la Tierra en un instante, convirtiendo ciudades en cenizas y tiñendo los cielos de un invierno perpetuo. El gran holocausto simplemente barrió la vida.

Tú estabas lejos del fuego, pero no de la catástrofe. Como científico líder de un proyecto de energía renovable en alta mar , la guerra te alcanzó. Una onda expansiva, un mar embravecido y el naufragio inevitable. El océano, transformado en un cementerio flotante, arrastró los restos de tu embarcación hacia lo desconocido."

func _ready():
	# Ponemos el texto invisible al principio
	texto_label.text = historia
	texto_label.visible_characters = 0
	
	# Le decimos al reloj que empiece a contar
	timer.timeout.connect(_on_timer_timeout)
	timer.start()

func _on_timer_timeout():
	# Si todavía quedan letras por mostrar...
	if texto_label.visible_characters < texto_label.get_total_character_count():
		texto_label.visible_characters += 1 # Mostramos una letra más
		
		# Si la letra no es un espacio vacío, suena el "bip"
		if historia[texto_label.visible_characters - 1] != " ":
			sonido_bip.play()
	else:
		# Si ya se escribieron todas las letras, el reloj se detiene
		timer.stop()
