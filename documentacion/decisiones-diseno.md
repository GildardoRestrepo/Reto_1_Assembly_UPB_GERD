# Decisiones de diseño

> Este documento registra y **justifica** las decisiones de hardware/firmware.
> La rúbrica evalúa que *tú* justifiques cada elección (registros, pines, tiempos).

## 1. Reloj del sistema — **HSI 16 MHz** (DECIDIDO)

Se usa el oscilador interno **HSI a 16 MHz**, que es el reloj de sistema por
defecto tras un reset, **sin configurar el PLL**.

**Justificación:** minimiza la cantidad de registros a configurar y elimina el
riesgo de configurar mal la latencia de FLASH y el PLL. Para conmutar LEDs con
resolución de milisegundos, 16 MHz es más que suficiente. La fuente de reloj de
SysTick se fijará al reloj del procesador (16 MHz).

## 2. Asignación de pines de los LEDs — *(PENDIENTE: tu decisión)*

**Recomendación:** usar **8 pines contiguos de un mismo puerto** (p. ej.
`PD0`–`PD7`). Ventaja: el "bit caminante" del barrido es un único
desplazamiento sobre el byte bajo de `ODR`, lo que puntúa directo en el criterio
de *manipulación eficiente de bits*.

| Recurso        | Pin(es) propuesto | ¿Confirmado? | Justificación |
|----------------|-------------------|--------------|---------------|
| 8 LEDs         | PD0–PD7           | ⬜           | *(completa)*  |
| Pulsador N.O.  | *(por definir)*   | ⬜           | *(completa)*  |
| LED objetivo   | central (PD3 o PD4)| ⬜          | *(completa)*  |

**Tarea tuya:** verifica en el pinout/serigrafía de tu placa "Black" que los
pines elegidos estén libres en los headers y no choquen con nada de la placa,
y completa la justificación.

## 3. Pulsador N.O. — resistencia interna *(PENDIENTE)*

Dos estrategias válidas (elige y justifica):
- **Pull-up interno** + botón a GND → reposo lee `1`, pulsado lee `0`.
- **Pull-down interno** + botón a VCC → reposo lee `0`, pulsado lee `1`.

## 4. Estrategia de debouncing *(se define en Fase 3)*
## 5. Estrategia del efecto visual de barrido *(se define en Fase 2)*
