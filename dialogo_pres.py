dialogo = [
 "¡Hola! Soy Vandana, la Ingeniera Solar de esta aldea.",
 "Aquí construimos energía limpia: paneles solares, turbinas eólicas y biomasa.",
 "¡Sigue construyendo un mundo más verde, aventurero!",
]

def interactuar_con_npc(jugador):
 """Cuando el jugador interactúa con el NPC."""
 jugador["movimiento_congelado"] = True # congela al personaje

 for linea in dialogo:
 mostrar_cuadro_texto(linea)
 esperar_tecla_interaccion() 

 jugador["movimiento_congelado"] = False 


def mostrar_cuadro_texto(texto):
 print(f" Vandana: {texto}")


def esperar_tecla_interaccion():
 input("[Presiona Enter / clic para continuar]")


if __name__ == "__main__":
 jugador = {"movimiento_congelado": False}
 interactuar_con_npc(jugador)
 print(f"movimiento_congelado = {jugador['movimiento_congelado']}")
