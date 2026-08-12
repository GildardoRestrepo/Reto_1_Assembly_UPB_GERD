# Tabla de registros configurados

> Deliverable. Se va llenando a medida que avanzan las fases.
> Fuente de direcciones: **RM0090** (Reference Manual STM32F407).

Bases de referencia:
- `RCC`   = `0x40023800`
- `GPIOA` = `0x40020000`, y cada puerto siguiente +`0x400` (GPIOD = `0x40020C00`, GPIOE = `0x40021000`).

## Fase 1 — Encender un LED (PD0)

| Registro     | Base        | Offset | Dirección final | Bits afectados        | Valor          | Justificación |
|--------------|-------------|--------|-----------------|-----------------------|----------------|---------------|
| RCC_AHB1ENR  | 0x40023800  | 0x30   | 0x40023830      | bit 3 (GPIODEN)       | `1`            | Habilita el reloj del puerto D; sin él, GPIOD no responde. |
| GPIOD_MODER  | 0x40020C00  | 0x00   | 0x40020C00      | bits [1:0] (PD0)      | `01`           | Configura PD0 como salida digital de propósito general. |
| GPIOD_ODR    | 0x40020C00  | 0x14   | 0x40020C14      | bit 0 (PD0)           | `1`            | Pone PD0 en alto → enciende el LED. |

## Fase 2 — SysTick + barrido
*(por completar: STK_CTRL, STK_LOAD, STK_VAL, MODER completo del puerto)*

## Fase 3 — Botón + debouncing
*(por completar: MODER/PUPDR del pin del pulsador, lectura por IDR)*
