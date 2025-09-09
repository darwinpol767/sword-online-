extends CharacterBody2D

@export var speed := 200
@export var jump_force := -400
@export var gravity := 900

func _physics_process(delta):
	# Aplicar gravedad
	if not is_on_floor():
		velocity.y += gravity * delta

	# Movimiento horizontal
	var input_dir = Input.get_axis("ui_left", "ui_right")
	velocity.x = input_dir * speed

	# Salto
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_force

	move_and_slide()
