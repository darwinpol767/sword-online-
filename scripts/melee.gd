extends CharacterBody2D

@export var velocidad: float = 50
@export var vida: int = 80
@export var daño: int = 10
@export var costo: int = 50        # se descuenta al crear
@export var cooldown: float = 2.0   # cooldown de creación
@export var cooldown_ataque: float = 1.0

var objetivo = null
var tiempo_ataque: float = 0.0

func _physics_process(delta):
	if vida <= 0:
		queue_free()
		return

	if objetivo and objetivo.vida > 0:
		atacar(delta)
	else:
		mover()

func mover():
	velocity.x = velocidad   # Aliados van a la derecha
	move_and_slide()

func atacar(delta):
	tiempo_ataque += delta
	if tiempo_ataque >= cooldown_ataque:
		if objetivo:
			if objetivo.has_method("recibir_daño"):
				objetivo.recibir_daño(daño)
			elif "vida" in objetivo:
				objetivo.vida -= daño
		tiempo_ataque = 0

func _on_Area2D_area_entered(area):
	var otra = area.get_parent()
	if otra != self and (("vida" in otra) or otra.has_method("recibir_daño")):
		objetivo = otra
