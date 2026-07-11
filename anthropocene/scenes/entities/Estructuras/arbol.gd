extends Area2D

# Variables para conectar el trabajo de Uriel y Jun desde el Inspector
@export var escena_item_drop: PackedScene
@export var datos_comida: Resource 

var jugador_cerca: bool = false
var ya_recolectado: bool = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.name == "Player" and not ya_recolectado:
		jugador_cerca = true
		print("Presiona E para sacudir el árbol")

func _on_body_exited(body):
	if body.name == "Player":
		jugador_cerca = false

func _process(_delta):
	# Detecta la interacción con la tecla E
	if jugador_cerca and Input.is_action_just_pressed("interact") and not ya_recolectado:
		soltar_comida()

func soltar_comida():
	ya_recolectado = true
	print("¡Cayó comida!")
	
	# Instanciar el objeto físico en el mundo
	if escena_item_drop and datos_comida:
		var nuevo_item = escena_item_drop.instantiate()
		nuevo_item.datos_del_item = datos_comida
		# Aparece un poco más arriba para que caiga
		nuevo_item.global_position = global_position + Vector2(0, -50) 
		get_tree().current_scene.add_child(nuevo_item)
