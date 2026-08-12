# Tabla de registros configurados

> Deliverable: Se va llenando a medida que avanzan las fases.
> Fuente de direcciones: docs/**RM0090** (Reference Manual STM32F407).

Bases de referencia:
- `RCC`     = `0x40023800`
- `GPIOA`   = `0x40020000`, y cada puerto siguiente +`0x400` (GPIOD = `0x40020C00`, GPIOE = `0x40021000`).
- `SysTick` = `0xE000E010` 

## Fase 1 — Encender un LED (PD0)

| Registro     | Base        | Offset | Dirección final | Bits afectados        | Valor          | Justificación |
|--------------|-------------|--------|-----------------|-----------------------|----------------|---------------|
| RCC_AHB1ENR  | 0x40023800  | 0x30   | 0x40023830      | bit 3 (GPIODEN)       | `1`            | Habilita el reloj del puerto D; sin él, GPIOD no responde. |
| GPIOD_MODER  | 0x40020C00  | 0x00   | 0x40020C00      | bits [1:0] (PD0)      | `01`           | Configura PD0 como salida digital de propósito general. |
| GPIOD_ODR    | 0x40020C00  | 0x14   | 0x40020C14      | bit 0 (PD0)           | `1`            | Pone PD0 en alto → enciende el LED. |

## Fase 2 — SysTick + barrido

| Registro | Base | Offset | Dirección final | Bits afectados | Valor | Justificación |
|----------|------|--------|-----------------|----------------|-------|---------------|
| STK_CTRL | 0xE000E010 | 0x00 | 0xE000E010 | bits 0,1,2 | `0x5` | ENABLE(0)=1 y CLKSOURCE(2)=1 (reloj del procesador); TICKINT(1)=0 → sondeo (polling). |
| STK_LOAD | 0xE000E010 | 0x04 | 0xE000E014 | bits [23:0] | `15999` = `0x3E7F` | Recarga para un tick de 1 ms a 16 MHz: RELOAD = f·T − 1. |
| STK_VAL  | 0xE000E010 | 0x08 | 0xE000E018 | — | `0` | Escribir cualquier valor pone el contador a 0 y limpia COUNTFLAG. |
| GPIOD_MODER | 0x40020C00 | 0x00 | 0x40020C00 | bits [15:0] | `0x5555` | PD0–PD7 como salida: `01` en cada uno de los 8 pines (leer-modificar-escribir para no tocar PD8–PD15). |
| GPIOD_ODR   | 0x40020C00 | 0x14 | 0x40020C14 | bits [7:0] | dinámico (bit caminante) | Patrón del LED encendido; cambia en runtime durante el barrido. |

## Fase 3 — Botón + debouncing (K1 / PE3)

| Registro | Base | Offset | Dirección final | Bits afectados | Valor | Justificación |
|----------|------|--------|-----------------|----------------|-------|---------------|
| RCC_AHB1ENR | 0x40023800 | 0x30 | 0x40023830 | bit 4 (GPIOEEN) | `1` | Habilita el reloj del puerto E (donde está K1/PE3). |
| GPIOE_MODER | 0x40021000 | 0x00 | 0x40021000 | bits [7:6] (PE3) | `00` | PE3 como entrada (es el valor por reset; se deja explícito). |
| GPIOE_PUPDR | 0x40021000 | 0x0C | 0x4002100C | bits [7:6] (PE3) | `01` | Pull-up interno → en reposo lee 1, pulsado lee 0 (activo-bajo). |
| GPIOE_IDR   | 0x40021000 | 0x10 | 0x40021010 | bit 3 (PE3) | lectura | Se lee el estado del botón (0 = pulsado). |

> El antirrebote no configura registros nuevos: relee `IDR` tras esperar ~20 ms con SysTick.

## Fase 4 — Juego (Ruleta de Precisión)
*(No configura registros nuevos: reutiliza `GPIOD_ODR` para los LEDs, `GPIOE_IDR` para el botón y `SysTick` para los tiempos de parpadeo y congelamiento.)*
