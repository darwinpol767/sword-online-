extends CharacterBody2D

# Variables exportadas para modificar desde el editor
@export var velocidad: float = 30
@export var vida: int = 100
@export var daño: int = 15
@export var cooldown_ataque: float = 1.0   # tiempo entre ataques

# Variables internas
var objetivo = null        # a quién está atacando actualmente
var puede_atacar = true    # control del cooldown de ataque
var esta_muerto = false    # control de estado de muerte

# Referencias a nodos
@onready var detector = $Area2D
@onready var animation_player = $AnimationPlayer
@onready var sprite = $Sprite2D

func _ready():
	# Conectar las señales del área
	detector.body_entered.connect(_on_body_entered)
	detector.body_exited.connect(_on_body_exited)
	
	# Agregar al grupo de enemigos
	add_to_group("enemigos")
	
	# Reproducir animación inicial de caminata
	animation_player.play("camina")

func _physics_process(_delta):
	if esta_muerto:
		return  # No hacer nada si está muerto
	
	# Si no hay objetivo → avanzar hacia la izquierda (enemigos van hacia izquierda)
	if objetivo == null:
		velocity.x = -velocidad  # ← Negativo para ir hacia izquierda
		move_and_slide()
		
		# Animación de caminata si no está reproduciéndose
		if animation_player.current_animation != "camina":
			animation_player.play("camina")
	else:
		# Si hay objetivo → detenerse
		velocity = Vector2.ZERO
		
		# Si estaba caminando, detener la animación (no hay idle)
		if animation_player.current_animation == "camina":
			animation_player.stop()  # ← Solo detener, no cambiar a idle
			
		if puede_atacar:
			atacar()

func atacar():
	# Verifica que el objetivo tenga la función "take_damage"
	if objetivo and objetivo.has_method("take_damage"):
		print("Enemigo golpea a ", objetivo.name)
		
		# Reproducir animación de ataque
		animation_player.play("ataque")
		
		# Esperar un poco para que coincida con la animación
		await get_tree().create_timer(0.2).timeout
		
		# Aplicar daño durante la animación
		objetivo.take_damage(daño)

		# Activar cooldown para evitar ataques instantáneos
		puede_atacar = false
		await get_tree().create_timer(cooldown_ataque).timeout
		puede_atacar = true

func take_damage(cantidad: int):
	if esta_muerto:
		return  # Ignorar daño si ya está muerto
	
	# Reducir la vida
	vida -= cantidad
	print("Enemigo recibe daño: ", cantidad, " Vida: ", vida)
	
	# Efecto visual de daño (parpadeo)
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	tween.tween_property(sprite, "modulate", Color.RED, 0.1)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)

	# Si se queda sin vida → morir
	if vida <= 0:
		morir()

func morir():
	if esta_muerto:
		return
	
	esta_muerto = true
	print("Enemigo muere!")
	
	# Desactivar colisiones y física
	set_physics_process(false)
	$CollisionShape2D.disabled = true
	
	# Reproducir animación de muerte
	animation_player.play("muerte")
	
	# Esperar a que termine la animación antes de eliminar
	await animation_player.animation_finished
	
	# Pequeña pausa adicional
	await get_tree().create_timer(0.5).timeout
	
	queue_free()

# Cuando entra un cuerpo en el área de detección
func _on_body_entered(body):
	if body.is_in_group("jugadores") and not esta_muerto:  # ← Ahora detecta jugadores
		objetivo = body
		# Detener animación de caminata (no hay idle)
		if animation_player.current_animation == "camina":
			animation_player.stop()

# Cuando sale un cuerpo del área
func _on_body_exited(body):
	if body == objetivo:
		objetivo = null
		# Volver a animación de caminata si no hay objetivos
		if not esta_muerto:
			animation_player.play("camina")
