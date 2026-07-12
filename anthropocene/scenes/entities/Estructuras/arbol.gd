extends Area2D

# Variables para conectar el trabajo de Uriel y Jun desde el Inspector
@export var escena_item_drop: PackedScene
@export var datos_comida: Resource 

var jugador_cerca: bool = false
var boost_activo: bool = false

# Tiempos de configuración en segundos
var tiempo_nomral: float = 10.0
var tiempo_boost: float = 2.0
var duracion_boost: float = 12.0

# Referencias a los temporizadores
@onready var timer_drop = $TimerDrop
@onready var timer_boost = $TimerBoost

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Conectamos los temporizadores de forma limpia por código
	timer_drop.timeout.connect(_on_timer_drop_timeout)
	timer_boost.timeout.connect(_on_timer_boost_timeout)
	
	# Iniciar el ciclo de produccin normal (X tiempo) de forma pasiva
	timer_drop.wait_time = tiempo_nomral
	timer_drop.start()

func _on_body_entered(body):
	if body.name == "Player":
		jugador_cerca = true
		if not boost_activo:
			print("Presiona E para aplicar agua y abono al árbol")

func _on_body_exited(body):
	if body.name == "Player":
		jugador_cerca = false

func _process(_delta):
	# Detecta la interacción para potenciar el árbol si no está activo el boost
	if jugador_cerca and Input.is_action_just_pressed("interact") and not boost_activo:
		aplicar_agua_y_abono()

# Esta funcián se ejecuta automóticamente cada vez que el TimerDrop llega a cero
func _on_timer_drop_timeout():
	soltar_comida()

func soltar_comida():
	print("El árbol produjo comida!")
	if escena_item_drop and datos_comida:
			var nuevo_item = escena_item_drop.instantiate()
			nuevo_item.datos_del_item = datos_comida
			nuevo_item.global_position = global_position + Vector2(0, -50)
			get_tree().current_scene.add_child(nuevo_item)

func aplicar_agua_y_abono():
	boost_activo = true
	print("Árbol abonado! ProducciÁn acelerada")
	
	# Cambiamos el intervalo de caóda al tiempo rapido y lo reiniciamos
	timer_drop.wait_time = tiempo_boost
	timer_drop.start()
	
	# Activamos el temporizador que apagará el efecto boost
	timer_boost.wait_time = duracion_boost
	timer_boost.one_shot = true # Importante que solo se ejecute una vez
	timer_boost.start()

# Se ejecuta cuando termina el tiempo de boost
func _on_timer_boost_timeout():
	print("El efecto del abono y el agua ha terminado. Producción volviendo a la normalidad")
	boost_activo = false
	
	# Regresamos el temporizador a su ritmo normal 
	timer_drop.wait_time = tiempo_nomral
	timer_drop.start()
