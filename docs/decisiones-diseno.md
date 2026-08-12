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
| 8 LEDs         | PD0–PD7           |       X     | Pines contiguos - Numeración continua  |
| Pulsador N.O.  | PE3 (botón K1)   |       X    | Facilidad de acceso - Botón en la esquina  |
| LED objetivo   | PD3 |     X    | LED central  |


## 3. Pulsador K1

Opción:
- **Pull-up interno** -> botón a GND → reposo lee `1`, pulsado lee `0`.  


## 4. Estrategia de debouncing

