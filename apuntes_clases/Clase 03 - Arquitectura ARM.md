---
tags:
  - tipo/clase
---
---
# Microprocesadores
22/07/2026

---
## Introducción
ARM es una arquitectura basada en `Harvard Modificada`, y ahora, toda una comunidad de fabricantes.
Una de sus características más relevantes es el bajo consumo de potencia.

Unos productos específicos de esta arquitectura son los modelos `Cortex`.
- **Cortex-A:** Optimizadas para sistemas operativos - Mayor rendimiento
- **Cortex-R:** Respuesta en tiempo real
- **Cortex-M:** Bajo consumo

---
### Actividad 1: Exploración del Mapa de Memoria
**Objetivo**: Familiarizarse con el mapa de memoria del STM32F407.
**Materiales**: Reference Manual RM0090 (capítulo 2 - Memory map)

| Periférico     | Dirección Base | Bus  | Región de Memoria |
| -------------- | -------------- | ---- | ----------------- |
| GPIOA          |                | AHB1 |                   |
| USART1         |                | APB2 |                   |
| TIM2           |                | APB1 |                   |
| ADC1           |                | APB2 |                   |
| NVIC           |                |      |                   |
| SRAM (inicio)  |                |      |                   |
| Flash (inicio) |                | AHB1 |                   |

---
## Instruction Set Architecture (ISA)
Para diseñar la `ISA` de un microcontrolador `ARM Cortex-M` se deben tner en cuenta las siguientes cosas:
1. Obtención de los datos.
2. Manipulación de los datos.

Para un `ARM Cortex-M` hay 16 `registros` visibles para usuarios.
#### R0 - R12: Registros de Uso General
**R0 - R3**: Registros de argumentos y resultados
- Parámetros de función (según AAPCS - ARM Architecture Procedure Call Standard)
- R0: Primer parámetro y valor de retorno
- R1-R3: Parámetros adicionales
- No se preservan automáticamente en llamadas a función

**R4 - R11**: Registros preservados
- Deben preservarse en llamadas a función (callee-saved)
- Útiles para variables locales que persisten entre llamadas

**R12 (IP)**: Intra-Procedure-call scratch register
- Uso temporal en llamadas
- No se preserva

#### R13 - R15: Registros Especiales
**R13 (SP) - Stack Pointer**:
- Apunta al tope del stack
- Dos versiones: MSP (Main) y PSP (Process)
- Decrece al hacer PUSH, crece al hacer POP
- Debe mantenerse alineado a 8 bytes (AAPCS)

**R14 (LR) - Link Register**:
- Almacena dirección de retorno al llamar función
- Permite retornar con `BX LR`
- En interrupciones, contiene EXC_RETURN (valor especial)

**R15 (PC) - Program Counter**:
- Apunta a instrucción actual + 4 (por pipeline)
- Se modifica con instrucciones de salto (B, BL, BX)
- Lectura directa da dirección de instrucción + offset

---
## Enlaces
[[Ing. Electrónica]]