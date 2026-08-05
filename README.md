# Ruleta de Precisión — STM32F407 (Assembly bare-metal)

Firmware a nivel de registros en **ARM Thumb-2** para el reto "Ruleta de Precisión"
(Unidad 1, Microcontroladores). Un LED barre entre 8 LEDs discretos; el usuario
presiona un botón intentando acertar cuando el **LED objetivo (central)** está encendido.

- **Acierto** → se detiene y el LED objetivo parpadea 3 veces.
- **Fallo** → congela 2 s el LED erróneo y reinicia el barrido.

Todo **bare-metal**: manipulación directa de registros, **sin HAL/SPL/CMSIS-Driver**,
temporización **solo con SysTick en polling**, y **debouncing por software**.

## Hardware objetivo
- MCU: **STM32F407VET6** (Cortex-M4), placa "Black".
- 8 LEDs discretos externos + 1 pulsador N.O. en protoboard.
- Reloj: **HSI 16 MHz** (por defecto tras reset, sin PLL).

## Estructura del repositorio
```
src/    -> código ensamblador (.s), un archivo por responsabilidad
docs/   -> documentación técnica exigida por la rúbrica
datasheets/ -> RM0090 (reference manual) y apuntes de clase
```

## Cómo compilar y flashear
Debido a que Segger Embedded Studio no lee el ST-Link de esta placa, el flujo es:

1. **Build** en Segger Embedded Studio → genera el binario en `Output/.../`
   (configurar la salida para producir `.hex`).
2. Abrir **STM32CubeProgrammer**, conectar el ST-Link, cargar el `.hex` en la
   dirección base **`0x08000000`** y programar.
3. Reset físico de la placa.

## Estado
- [x] Fase 0 — Infraestructura del repositorio
- [ ] Fase 1 — Arranque bare-metal: encender 1 LED (valida el toolchain)
- [ ] Fase 2 — Barrido de 8 LEDs con SysTick
- [ ] Fase 3 — Lectura del botón + debouncing
- [ ] Fase 4 — Lógica del juego (acierto / fallo / reinicio)
- [ ] Fase 5 — Documentación final (tabla de registros, cálculos, diagramas)
