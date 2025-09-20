extends CharacterBody2D

@export var velocidad: float = 50
@export var vida: int = 100
@export var daño: int = 10
@export var ataque_cooldown: float = 1.0

var objetivo = null
var puede_atacar = true
@onready var detector = $Area2D

func _ready():
	detector.body_entered.connect(_on_body_entered)
	detector.body_exited.connect(_on_body_exited)

func _physics_process(delta):
	if objetivo == null:
		velocity.x = velocidad
		move_and_slide()
	else:
		velocity = Vector2.ZERO
		if puede_atacar:
			atacar()

func atacar():
	if objetivo and objetivo.has_method("recibir_daño"):
		print("Aliado golpea a ", objetivo.name)
		objetivo.recibir_daño(daño, self)
		puede_atacar = false
		await get_tree().create_timer(ataque_cooldown).timeout
		puede_atacar = true

func recibir_daño(cantidad, atacante):
	vida -= cantidad
	print("Aliado recibe daño: ", cantidad, " Vida: ", vida)
	if vida <= 0:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("enemigos") or body.is_in_group("base_enemiga"):
		objetivo = body

func _on_body_exited(body):
	if body == objetivo:
		objetivo = null
