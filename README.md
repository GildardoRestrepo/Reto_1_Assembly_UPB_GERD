# Ruleta de Precisión — STM32F407 (Assembly bare-metal)

---

Autor: Gildardo E. Restrepo, 
Curso: Microcontroladores, 
Semestre: 2026-02

---

Firmware a nivel de registros en **ARM Thumb-2** para el reto "Ruleta de Precisión"
(Unidad 1, Microcontroladores). Se realiza un barrido entre 8 leds que se van encendiendo; el usuario
presiona un botón intentando acertar cuando el **LED objetivo (central)** está encendido.

- **Acierto** → se detiene y el LED objetivo parpadea 3 veces.
- **Fallo** → congela 2 s el LED erróneo y reinicia el barrido.

Todo **bare-metal**: manipulación directa de registros, **sin HAL/SPL/CMSIS-Driver**,
temporización **con SysTick en polling**, y **debouncing por software**.

## Hardware objetivo
- MCU: **STM32F407VET6** (Cortex-M4), placa "Black".
- 8 LEDs discretos externos + 1 pulsador N.O. en protoboard. Se usa una matriz de leds + pulsador de la tarjeta.
- Reloj: **HSI 16 MHz** (por defecto tras reset, sin PLL).

## Estructura del repositorio
```

apuntes_clases/  -> apuntes .md de las clases vistas (desarrollados en Obisidian)
datasheets&pinouts/ -> RM0090 (reference manual) y apuntes de clase
documentacion/   -> documentación por etapas del desarrollo del proyecto
segger/  -> Proyecto generado en Segger
src/    -> código ensamblador (.s), un archivo por responsabilidad. 

```

## Compilación y flasheo

1. **Build** en Segger Embedded Studio → genera el binario en `Output/.../`
   (salida configurada en `.hex`).
2. Se usa **STM32CubeProgrammer** con el ST-Link, se carga el `.hex` en la
   dirección base **`0x08000000`** y se programa.
3. Reset físico de la placa.

## Estado
- [x] Fase 0 — Infraestructura del repositorio
- [x] Fase 1 — Arranque bare-metal: encender 1 LED (validando toolchain)
- [x] Fase 2 — Barrido de 8 LEDs con SysTick.                                              
- [X] Fase 2.1 - Configurar rebote del barrido de LEDs como adicional al juego.
- [X] Fase 3 — Lectura del botón + debouncing
- [ ] Fase 4 — Lógica del juego (acierto / fallo / reinicio)
- [ ] Fase 5 — Documentación final (tabla de registros, cálculos, diagramas)
