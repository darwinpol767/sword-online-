import tkinter as tk
import random

# =====================
# VARIABLES GLOBALES
# =====================
ANCHO = 600
ALTO = 400
velocidad = 10
puntaje = 0
jugador = None
paquete = None
cliente = None
enemigos = []
obstaculos = []
juego_activo = False
max_enemigos = 10

# =====================
# FUNCIONES PRINCIPALES
# =====================
def mover_jugador(event):
    """Mueve el carrito con WASD"""
    if not juego_activo:
        return

    x, y = 0, 0
    if event.keysym.lower() == "w":
        y = -velocidad
    elif event.keysym.lower() == "s":
        y = velocidad
    elif event.keysym.lower() == "a":
        x = -velocidad
    elif event.keysym.lower() == "d":
        x = velocidad

    canvas.move(jugador, x, y)
    mover_enemigos()
    detectar_colision()

def mover_enemigos():
    """Cada enemigo persigue al jugador"""
    jx1, jy1, jx2, jy2 = canvas.bbox(jugador)

    for enemigo in enemigos:
        ex1, ey1, ex2, ey2 = canvas.bbox(enemigo)
        dx = (jx1 - ex1) // 25
        dy = (jy1 - ey1) // 25
        canvas.move(enemigo, dx, dy)

def detectar_colision():
    """Detecta colisiones con paquete, cliente, enemigo u obstáculo"""
    global paquete, cliente, puntaje

    jugador_coords = canvas.bbox(jugador)

    # Colisión con paquete (marijuana)
    if paquete and colision(jugador_coords, canvas.bbox(paquete)):
        canvas.delete(paquete)
        paquete = None
        crear_cliente()

    # Colisión con cliente (entrega)
    if cliente and colision(jugador_coords, canvas.bbox(cliente)):
        canvas.delete(cliente)
        cliente = None
        puntaje += 1
        actualizar_puntaje()
        crear_paquete()

        # Cada 3 puntos aparece un nuevo enemigo (hasta 10)
        if puntaje % 3 == 0 and len(enemigos) < max_enemigos:
            crear_enemigo()

    # Colisión con enemigos
    for enemigo in enemigos:
        if colision(jugador_coords, canvas.bbox(enemigo)):
            fin_juego()
            return

    # Colisión con obstáculos
    for obst in obstaculos:
        if colision(jugador_coords, canvas.bbox(obst)):
            fin_juego()
            return

def colision(a, b):
    """Verifica si dos áreas se superponen"""
    return not (a[2] < b[0] or a[0] > b[2] or a[3] < b[1] or a[1] > b[3])

def actualizar_puntaje():
    etiqueta_puntaje.config(text=f"Puntaje: {puntaje}")

# =====================
# CREACIÓN DE ELEMENTOS
# =====================
def crear_jugador():
    global jugador
    jugador = canvas.create_rectangle(280, 180, 310, 210, fill="blue")

def crear_paquete():
    global paquete
    x = random.randint(50, ANCHO-50)
    y = random.randint(50, ALTO-50)
    paquete = canvas.create_rectangle(x, y, x+20, y+20, fill="purple")

def crear_cliente():
    global cliente
    x = random.randint(50, ANCHO-50)
    y = random.randint(50, ALTO-50)
    cliente = canvas.create_rectangle(x, y, x+20, y+20, fill="lightblue")

def crear_enemigo():
    enemigo = canvas.create_rectangle(50, 50, 80, 80, fill="red")
    enemigos.append(enemigo)

def crear_decoracion():
    """Agrega obstáculos que ahora SÍ son colisionables"""
    global obstaculos
    obstaculos.clear()

    for _ in range(5):
        x = random.randint(50, ANCHO-70)
        y = random.randint(50, ALTO-70)
        arbol = canvas.create_oval(x, y, x+30, y+30, fill="green")
        obstaculos.append(arbol)

    for _ in range(3):
        x = random.randint(50, ANCHO-70)
        y = random.randint(50, ALTO-70)
        roca = canvas.create_polygon(x, y, x+20, y+40, x-20, y+40, fill="brown")
        obstaculos.append(roca)

# =====================
# PANTALLAS
# =====================
def iniciar_juego():
    global puntaje, juego_activo, enemigos
    puntaje = 0
    enemigos.clear()
    juego_activo = True
    canvas.delete("all")
    crear_decoracion()
    crear_jugador()
    crear_paquete()
    crear_enemigo()  # Primer enemigo
    actualizar_puntaje()
    canvas.focus_set()
    canvas.bind("<KeyPress>", mover_jugador)
    boton_empezar.config(state="disabled")

def fin_juego():
    global juego_activo
    juego_activo = False
    canvas.create_text(ANCHO//2, ALTO//2, text="¡Te atraparon!\n", font=("Arial", 18), fill="red")

    # Mostrar botones de reintentar/salir
    boton_reintentar.pack(side="left", padx=5)
    boton_salir.pack(side="left", padx=5)
    boton_reintentar.config(state="normal")
    boton_salir.config(state="normal")

def reiniciar_juego():
    boton_reintentar.pack_forget()
    boton_salir.pack_forget()
    iniciar_juego()

# =====================
# INTERFAZ
# =====================
ventana = tk.Tk()
ventana.title("El Carrito del Mal")
ventana.geometry("700x500")

# Frame superior
frame_superior = tk.Frame(ventana, pady=10)
frame_superior.pack()
etiqueta_puntaje = tk.Label(frame_superior, text="Puntaje: 0", font=("Arial", 14))
etiqueta_puntaje.pack()

# Canvas (área de juego)
canvas = tk.Canvas(ventana, width=ANCHO, height=ALTO, bg="lightgrey")
canvas.pack()

# Frame inferior (controles)
frame_inferior = tk.Frame(ventana, pady=10)
frame_inferior.pack()
boton_empezar = tk.Button(frame_inferior, text="Empezar", command=iniciar_juego)
boton_empezar.pack(side="left", padx=5)

boton_reintentar = tk.Button(frame_inferior, text="Reintentar", command=reiniciar_juego, state="disabled")
boton_salir = tk.Button(frame_inferior, text="Salir", command=ventana.destroy, state="disabled")

ventana.mainloop()
