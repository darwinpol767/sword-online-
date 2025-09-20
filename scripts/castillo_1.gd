extends StaticBody2D
@export var max_health: int = 500   # vida máxima de la base
var current_health: int

# Este se ejecuta al iniciar
func _ready():
	current_health = max_health
	update_health_label()

# Función para recibir daño
func take_damage(amount: int) -> void:
	current_health -= amount
	update_health_label()

	if current_health <= 0:
		die()

# Actualiza el Label para mostrar la vida actual
func update_health_label():
	$Label.text = str(current_health) + " / " + str(max_health)

# Si la base muere → terminar partida o mostrar mensaje
func die():
	print("¡Base destruida!")
	queue_free()  # elimina la base
