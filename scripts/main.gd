extends Node2D

# Unidades del jugador (asigna en el editor Soldado.tscn, Arquero.tscn, Tanque.tscn)
@export var unidades_jugador: Array[PackedScene]

# Unidades del enemigo (asigna en el editor EnemigoSoldado.tscn, EnemigoArquero.tscn, EnemigoTanque.tscn)
@export var unidades_enemigo: Array[PackedScene]

# Dinero inicial
var dinero: int = 300

# Cooldowns de los botones de tropas aliadas
var cooldowns_jugador: Array[float]

# Control del spawn automático de enemigos
var tiempo_spawn_enemigo: float = 0.0
@export var spawn_rate_enemigo: float = 5.0   # cada 5 seg aparece uno

func _ready():
	randomize()
	# preparar cooldowns
	cooldowns_jugador.resize(unidades_jugador.size())
	for i in range(cooldowns_jugador.size()):
		cooldowns_jugador[i] = 0.0

	# conectar botones del HUD
	$CanvasLayer/BotonSoldado.pressed.connect(func(): crear_unidad_jugador(0))
	$CanvasLayer/BotonArquero.pressed.connect(func(): crear_unidad_jugador(1))
	$CanvasLayer/BotonTanque.pressed.connect(func(): crear_unidad_jugador(2))

	actualizar_dinero()

func _process(delta):
	# actualizar cooldowns jugador
	for i in range(cooldowns_jugador.size()):
		if cooldowns_jugador[i] > 0:
			cooldowns_jugador[i] -= delta
			if cooldowns_jugador[i] < 0:
				cooldowns_jugador[i] = 0

	# spawn automático enemigo
	tiempo_spawn_enemigo += delta
	if tiempo_spawn_enemigo >= spawn_rate_enemigo:
		spawn_enemigo()
		tiempo_spawn_enemigo = 0

# ------------------------
# Crear tropas del jugador
# ------------------------
func crear_unidad_jugador(indice: int):
	var escena = unidades_jugador[indice]
	var nueva = escena.instantiate()

	if dinero < nueva.costo:
		print("No hay suficiente dinero")
		return

	if cooldowns_jugador[indice] > 0:
		print("Unidad en cooldown")
		return

	# descontar dinero
	dinero -= nueva.costo
	actualizar_dinero()

	# colocar en el spawn del jugador (Marker2D dentro de la base)
	nueva.position = $BaseJugador/SpawnJugador.position
	nueva.equipo = 0   # equipo jugador
	add_child(nueva)

	# iniciar cooldown de ese botón
	cooldowns_jugador[indice] = nueva.cooldown

# ------------------------
# Spawn automático enemigo
# ------------------------
func spawn_enemigo():
	var indice = randi() % unidades_enemigo.size()
	var escena = unidades_enemigo[indice]
	var nueva = escena.instantiate()

	# colocar en el spawn del enemigo (Marker2D dentro de la base enemiga)
	nueva.position = $BaseEnemiga/SpawnEnemigo.position
	nueva.equipo = 1   # equipo enemigo
	add_child(nueva)

# ------------------------
# Actualizar dinero en HUD
# ------------------------
func actualizar_dinero():
	$CanvasLayer/LabelDinero.text = "Dinero: %d" % dinero
