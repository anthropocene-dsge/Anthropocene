extends Area2D

@export var escena_item_drop: PackedScene
@export var datos_material: Resource
@export var tiempo_respawn: float = 10.0 # Segundos que tarda en reaparecer

var jugador_cerca: bool = false
var impactos: int = 0
var timer_respawn: Timer

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Creamos el cronómetro mágico por código para no ensuciar tu árbol de nodos
	timer_respawn = Timer.new()
	timer_respawn.one_shot = true
	timer_respawn.timeout.connect(_reaparecer_roca)
	add_child(timer_respawn)

func _on_body_entered(body):
	# Solo detectamos al jugador si la roca NO está destruida
	if body.name == "Player" and impactos < 3:
		jugador_cerca = true
		print("Presiona E para romper la roca")

func _on_body_exited(body):
	if body.name == "Player":
		jugador_cerca = false

func _process(_delta):
	# Solo podemos picar si estamos cerca, presionamos E, y la roca sigue viva
	if jugador_cerca and Input.is_action_just_pressed("interact") and impactos < 3:
		picar_roca()

func picar_roca():
	impactos += 1
	print("¡Picando roca! (" + str(impactos) + "/3)")
	
	if impactos >= 3:
		print("¡La roca se rompió! Reaparecerá en " + str(tiempo_respawn) + " segundos.")
		
		# 1. Escupimos el engranaje
		if escena_item_drop and datos_material:
			var nuevo_item = escena_item_drop.instantiate()
			nuevo_item.datos_del_item = datos_material
			nuevo_item.global_position = global_position + Vector2(0, -30)
			get_tree().current_scene.add_child(nuevo_item)
		
		# 2. Escondemos el dibujo de la roca
		$Sprite2D.visible = false
		
		# 3. Desactivamos el área de detección (para no poder seguir picando a la nada)
		$CollisionShape2D.set_deferred("disabled", true)
		
		# 4. Desactivamos el bloque sólido (para que el jugador pueda caminar por ahí)
		if has_node("StaticBody2D/CollisionShape2D"):
			get_node("StaticBody2D/CollisionShape2D").set_deferred("disabled", true)
			
		# 5. Arrancamos el cronómetro de reaparición
		timer_respawn.start(tiempo_respawn)

func _reaparecer_roca():
	print("¡Una roca ha reaparecido en el mapa!")
	
	# Reseteamos la "vida" de la roca
	impactos = 0
	
	# Le devolvemos su dibujo
	$Sprite2D.visible = true
	
	# Reactivamos sus colisiones para que vuelva a ser sólida e interactuable
	$CollisionShape2D.set_deferred("disabled", false)
	if has_node("StaticBody2D/CollisionShape2D"):
		get_node("StaticBody2D/CollisionShape2D").set_deferred("disabled", false)
