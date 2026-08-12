# Diagrama de flujo del software

---

Autor: Gildardo E. Restrepo
Curso: Microcontroladores
Semestre: 2026-02

---

## 1. Lógica general del juego

```mermaid
flowchart TD
    A(["Reset / Encendido"]) --> B["Habilitar relojes GPIOD y GPIOE (AHB1)"]
    B --> C["PD0-PD7 = salida ; PE3 = entrada con pull-up"]
    C --> D["Apagar todos los LEDs (estado inicial)"]
    D --> E["systick_init (base de tiempo, tick de 1 ms)"]
    E --> F["reiniciar: LED = PD0"]
    F --> G["Mostrar LED en ODR"]
    G --> H["delay_ms (STEP_MS)"]
    H --> I{"button_read: K1 pulsado?"}
    I -- No --> J["Avanzar bit (ping-pong PD0..PD7..PD1)"]
    J --> G
    I -- Si --> K{"LED encendido == objetivo PD3?"}
    K -- Si --> L["VICTORIA: parpadear PD3 tres veces"]
    K -- No --> M["FALLO: congelar el LED erroneo 2 s"]
    L --> F
    M --> F
```

## 2. Técnica de debouncing (rutina `button_read`)

```mermaid
flowchart TD
    A(["button_read"]) --> B["Leer IDR (bit 3 = PE3)"]
    B --> C{"bit == 1? (reposo)"}
    C -- Si --> D["return 0 (no pulsado)"]
    C -- No --> E["Esperar 20 ms (delay_ms)"]
    E --> F["Releer IDR (bit 3)"]
    F --> G{"sigue en 0?"}
    G -- "No (fue rebote)" --> D
    G -- Si --> H["return 1 (pulsacion valida)"]
```

## 3. Notas 

- **Inicialización**: El orden de arranque no es arbitrario. Primero se **habilita el reloj** de los puertos en RCC (GPIODEN para los LEDs, GPIOEEN para el botón): un periférico sin reloj no responde a las escrituras, así que esto va antes de cualquier configuración. Con el reloj activo se define el **modo** de los pines (PD0–PD7 como salida en MODER; PE3 como entrada con pull-up en PUPDR). Luego se **apagan todos los LEDs** escribiendo 0 en ODR, garantizando el estado inicial que exige el reto tras energizar o resetear. Por último se inicializan la **base de tiempo (SysTick)** y el **botón**, porque el bucle de juego depende de `delay_ms` y `button_read`. [src/main.s]
- **Rutina de barrido**: Se definen dos funciones de barrido para el avance y el rebote (llamadas barrido y retorno, respectivamente). Tras llegar a PD07 y sin la lógica de juego interrumpida, en lugar de retornar a PD0 se vuelve a PD6 y se inicia un barrido hacia la izquierda con la misma estructura de comparación que el barrido original. Al finalizar **retorno** llama a **barrido** para reiniciar el proceso.     
- **Debouncing**: Para evitar lecturas erróneas del botón debido a efectos mecánicos, el debouncing actúa como un proceso de doble verificación, evaluando el estado en dos momentos separados en el tiempo por 20ms (criterio técnico de diseño). [src/button.s]
- **Evaluación acierto/fallo**: El registro r4 es quien hace las veces de variable que almacena el LED actual encendido. Tras confirmar la lectura del botón mientras se ejecuta el barrido/rebote (con la técanica de debouncing), se entra en el bloque de evaluación que contiene 3 funciones: evaluar, fallo y victoria. Evaluar compara el registro r4 con el led objetivo y según dicho resultado se va hacia, o bien al bloque fallo, o bien al de victoria. Ambos bloques vuelven (b reiniciar) al bucle principal de juego. [src/main.s]
