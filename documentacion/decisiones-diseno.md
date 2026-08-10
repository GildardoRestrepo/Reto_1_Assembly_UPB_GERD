# Decisiones de diseño

---

Autor: Gildardo E. Restrepo
Curso: Microcontroladores
Semestre: 2026-02

---

> Este documento registra y **justifica** las decisiones de hardware/firmware.

## 1. Reloj del sistema — **HSI 16 MHz** (DECIDIDO)

Se usa el oscilador interno **HSI a 16 MHz**, que es el reloj de sistema por
defecto tras un reset, **sin configurar el PLL**.

**Justificación:** minimiza la cantidad de registros a configurar y elimina el
riesgo de configurar mal la latencia de FLASH y el PLL. Para conmutar LEDs con
resolución de milisegundos, 16 MHz es suficiente. La fuente de reloj de
SysTick se fijará al reloj del procesador (16 MHz).

## 2. Asignación de pines de los LEDs

| Recurso        | Pin(es) propuesto | ¿Confirmado? | Justificación |
|----------------|-------------------|--------------|---------------|
| 8 LEDs         | PD0–PD7           |       X     | *(completa)*  |
| Pulsador N.O.  | *(por definir)*   |           | *(completa)*  |
| LED objetivo   | central (PD3 o PD4)|         | *(completa)*  |


## 3. Pulsador N.O. — resistencia interna *(PENDIENTE)*

Dos opciones:
- **Pull-up interno** + botón a GND → reposo lee `1`, pulsado lee `0`.
- **Pull-down interno** + botón a VCC → reposo lee `0`, pulsado lee `1`.

## 4. Estrategia de debouncing *(se define en Fase 3)*

