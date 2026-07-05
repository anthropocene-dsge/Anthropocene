# 🌍 Anthropocene - MVP Supervivencia y Energía

¡Bienvenidos al repositorio oficial del proyecto! 

Esta es una demo de un juego de supervivencia en 2D centrado en el rescate y gestión de energías renovables en un mundo post-nuclear. Para garantizar que el desarrollo fluya sin errores, bloqueos de archivos o conflictos graves, **todo el equipo debe seguir estrictamente los siguientes pasos**.

---

## 1. Configuración del Entorno (Primera vez)

Para evitar que los archivos se corrompan, es obligatorio que todos utilicemos **exactamente la misma versión de Godot 4**. 

1. Clona este repositorio en tu computadora usando la terminal:
    ```bash
    git clone [https://github.com/tuxedomasck/Anthropocene.git](https://github.com/tuxedomasck/Anthropocene.git)
    ```
2. Abre **Godot Engine**.
3. En el Gestor de Proyectos, haz clic en **Importar** (Import).
4. Navega hasta la carpeta que acabas de clonar, entra a la subcarpeta `/anthropocene` y selecciona el archivo `project.godot`.
5. Haz clic en **Importar y Editar**.

---

## 2. Flujo de Trabajo Obligatorio (GitHub Flow)

**REGLA DE ORO: Nadie programa, guarda ni hace commits directamente en la rama `main`.** 

Trabajaremos utilizando *Issues* y *Ramas por Funcionalidad (Feature Branches)* para asegurar que el código siempre esté estable. El proceso para trabajar es el siguiente:

1. **Revisa los Issues:** Ve a la pestaña de "Issues" en GitHub y asígnate una tarea disponible.
2. **Actualiza tu base:** Antes de empezar, asegúrate de tener la última versión del juego:
    ```bash
    git checkout main
    git pull origin main
    ```
3. **Crea tu rama de trabajo:** Crea una rama nueva con el nombre de la funcionalidad que vas a programar. (Ejemplo: `feature/3-login-ui` o `feature/player-movement`).
    ```bash
    git checkout -b feature/nombre-de-tu-rama
    ```
4. **Programa en Godot:** Haz tu trabajo. Recuerda crear tus archivos solo en las carpetas designadas (`scenes`, `scripts`, etc.) y trabajar tus escenas como **Prefabs** independientes. **No modifiques la escena principal al mismo tiempo que otro compañero.**
5. **Sube tus cambios:** 
    ```bash
    git add .
    git commit -m "Descripción clara de lo que hiciste"
    git push origin feature/nombre-de-tu-rama
    ```
6. **Pull Request (PR):** Ve a GitHub y abre un PR desde tu rama hacia `main`. Solicita que alguien más revise tu código antes de fusionarlo.

---

## 📁 3. Arquitectura de Carpetas

Por favor, respeta la siguiente estructura para mantener el proyecto ordenado:

* `assets/`: Imágenes, sprites (exportados de Piskel), iconos, fuentes y música.
* `autoloads/`: Scripts globales que controlan el juego en segundo plano (ej. el gestor del JSON para guardar partidas).
* `data/`: Archivos de almacenamiento (ej. `default_save.json`).
* `scenes/`: 
  * `/ui`: Menús, login, HUD.
  * `/entities`: Jugador, recursos recolectables, generadores de energía.
  * `/level`: Los mapas y tilemaps.

---
*Si tienes dudas sobre un Merge Conflict o cómo instanciar tu escena, avisa al equipo antes de forzar un cambio en GitHub.* ¡A programar! 🚀
