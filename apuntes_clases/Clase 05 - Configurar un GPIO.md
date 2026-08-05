---
tags:
  - tipo/clase
---
# Microcontroladores
29/07/2026

---
## Instalación del entorno: Segger Embedded Studio 8.30
- Instalación.
- Agregar drivers de la tarjeta.
- Crear primer proyecto de ejemplo.

---
## Primer proyecto: 'GPIO_Test_1'
**GPIO:** Pines de entrada/salida de propósito general.
Revisar diagrama: Estructura básica de un puerto de bits entrada/salida con tolerancia de 5V. 

```assembly
/*********************************************************************
*                    SEGGER Microcontroller GmbH                     *
*                        The Embedded Experts                        *
**********************************************************************
*                                                                    *
*            (c) 2014 - 2024 SEGGER Microcontroller GmbH             *
*                                                                    *
*       www.segger.com     Support: support@segger.com               *
*                                                                    *
**********************************************************************
*                                                                    *
* All rights reserved.                                               *
*                                                                    *
* Redistribution and use in source and binary forms, with or         *
* without modification, are permitted provided that the following    *
* condition is met:                                                  *
*                                                                    *
* - Redistributions of source code must retain the above copyright   *
*   notice, this condition and the following disclaimer.             *
*                                                                    *
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND             *
* CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,        *
* INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF           *
* MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE           *
* DISCLAIMED. IN NO EVENT SHALL SEGGER Microcontroller BE LIABLE FOR *
* ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR           *
* CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT  *
* OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;    *
* OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF      *
* LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT          *
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE  *
* USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH   *
* DAMAGE.                                                            *
*                                                                    *
*********************************************************************/

/*********************************************************************
*
*       _start
*
*  Function description
*  Defines entry point for an STM32F4xx assembly code only
*  application.
*
*  Additional information
*    Please note, as this is an assembly code only project, the C/C++
*    runtime library has not been initialised. So do not attempt to call
*    any C/C++ library functions because they probably won't work.
*/

/* ==================== DIRECTIVAS DEL ENSAMBLADOR ==================== */
        .syntax unified          // Sintaxis unificada ARM/Thumb (obligatoria en Cortex-M)
        .global _start           // Hace visible la etiqueta _start (punto de entrada)
        .text                    // Sección de código ejecutable (va a la Flash)
        .thumb_func              // La siguiente etiqueta es una función Thumb

/* ==================== CONSTANTES (mapa de memoria) ==================== */
        // --- RCC: Reset and Clock Control (controla los relojes) ---
        .equ RCC_BASE, 0x40023800        // Dirección base del periférico RCC
        .equ RCC_AHB1ENR_OFFSET, 0x30    // Offset del registro que habilita relojes del bus AHB1
        .equ EN_RCC_PTA, 0X01            // Máscara: bit 0 = habilitar reloj de GPIOA

        // --- GPIOA: puerto de entrada/salida A ---
        .equ GPIOA_BASE, 0x40020000      // Dirección base de GPIOA
        .equ GPIOx_MODER_OFFSET, 0x00    // Offset de MODER (modo del pin: entrada/salida/...)
        .equ GPIOA_ODR_OFFSET, 0x14      // Offset de ODR (Output Data Register: valor de salida)

_start:
/* --- PASO 1: Habilitar el reloj de GPIOA (bit 0 de RCC_AHB1ENR) --- */
        // Sin reloj, el periférico está "muerto": no responde a escrituras.
        LDR R0, =RCC_BASE                    // R0 = dirección base del RCC
        LDR R1, [R0, #RCC_AHB1ENR_OFFSET]    // R1 = valor actual de RCC_AHB1ENR (LEER)
        ORR R2, R1, EN_RCC_PTA               // R2 = R1 | 0x01  -> pone el bit 0 a 1 (MODIFICAR)
        STR R2, [R0, #RCC_AHB1ENR_OFFSET]    // Guarda R2 de vuelta en el registro (ESCRIBIR)

/* --- PASO 2a: Poner un 1 en el bit 12 de MODER (MODER6[0]) --- */
        // Pin 6 usa los bits 12-13 de MODER. Queremos 01 = "salida".
        LDR R0, =GPIOA_BASE                  // R0 = base de GPIOA
        LDR R1, [R0, #GPIOx_MODER_OFFSET]    // R1 = MODER actual (LEER)
        MOV R2, 0x01                         // R2 = 1
        LSL R2, R2, #12                      // R2 = 1 << 12  -> máscara con un 1 en el bit 12
        ORR R3, R1, R2                       // R3 = R1 | máscara -> fuerza el bit 12 a 1
        STR R3, [R0, #GPIOx_MODER_OFFSET]    // Escribir de vuelta

/* --- PASO 2b: Poner un 0 en el bit 13 de MODER (MODER6[1]) --- */
        // Así el campo MODER6 queda en 01 (bit13=0, bit12=1) = salida.
        LDR R0, =GPIOA_BASE
        LDR R1, [R0, #GPIOx_MODER_OFFSET]    // R1 = MODER actual (LEER)
        MOV R2, 0x01
        LSL R2, R2, #13                      // R2 = 1 << 13 -> máscara con un 1 en el bit 13
        BIC R3, R1, R2                       // R3 = R1 & ~máscara -> fuerza el bit 13 a 0
        STR R3, [R0, #GPIOx_MODER_OFFSET]    // Escribir de vuelta

/* --- PASO 3: Encender el LED una vez (poner bit 6 del ODR a 1) --- */
        LDR R0, =GPIOA_BASE
        LDR R1, [R0, #GPIOA_ODR_OFFSET]      // R1 = ODR actual (LEER)
        MOV R3, 0x01
        ORR R2, R1, R3, LSL #6               // R2 = R1 | (1 << 6) -> pone el bit 6 a 1 (LED ON)
        STR R2, [R0, #GPIOA_ODR_OFFSET]      // Escribir de vuelta

/* --- PASO 4: Bucle infinito que apaga el LED (bit 6 del ODR a 0) --- */
loop:   LDR R0, =GPIOA_BASE
        LDR R1, [R0, #GPIOA_ODR_OFFSET]      // R1 = ODR actual (LEER)
        MOV R3, 0x01
        BIC R2, R1, R3, LSL #6               // R2 = R1 & ~(1 << 6) -> pone el bit 6 a 0 (LED OFF)
        STR R2, [R0, #GPIOA_ODR_OFFSET]      // Escribir de vuelta
        b loop                               // Repetir por siempre

/* NOTA: tal como está, este código enciende el LED una vez y luego lo mantiene
   APAGADO dentro del bucle (no parpadea). Para que PARPADEE hay que, dentro del
   loop: (1) encender, (2) esperar (delay), (3) apagar, (4) esperar (delay).
   Ver la sección "Cómo hacerlo parpadear" más abajo. */

```

---
## Explicación paso a paso

Todo el programa se apoya en un único patrón, el **read-modify-write** (leer–modificar–escribir):
`LDR` (leer el registro) → `ORR`/`BIC` con una máscara (modificar sólo los bits deseados) → `STR` (escribir de vuelta). Nunca se escribe un valor "a ciegas" para no pisar la configuración de los demás pines.

### Registros involucrados

| Registro       | Base + Offset            | Para qué sirve |
| -------------- | ------------------------ | -------------- |
| `RCC_AHB1ENR`  | `0x40023800 + 0x30`      | Habilita el **reloj** de los periféricos del bus AHB1 (incluye GPIOA). Bit 0 = GPIOA. |
| `GPIOA_MODER`  | `0x40020000 + 0x00`      | Define el **modo** de cada pin (2 bits por pin). Pin 6 → bits 12-13. |
| `GPIOA_ODR`    | `0x40020000 + 0x14`      | *Output Data Register*: el **valor de salida** de cada pin (1 bit por pin). Pin 6 → bit 6. |

### Por qué pin 6 = bits 12-13 en MODER
`MODER` usa **2 bits por pin**, así que el pin *y* ocupa los bits `2y` y `2y+1`. Para el pin 6: `2*6 = 12` y `2*6+1 = 13`. Los valores posibles del campo son:
`00` = entrada · `01` = **salida** · `10` = función alternativa · `11` = analógico.
Por eso el código pone el bit 12 a **1** y el bit 13 a **0** → campo `01` = salida.

### El truco del operando desplazado
`ORR R2, R1, R3, LSL #6` hace **dos cosas en una instrucción**: primero calcula `R3 << 6` (mueve el `1` a la posición del bit 6) y luego lo combina con `R1` mediante `OR`. Es la forma compacta de "poner a 1 el bit 6". Con `BIC` en vez de `ORR`, ese mismo `1` desplazado indica qué bit **borrar** (poner a 0).

### Qué hace el programa, en orden
1. **Enciende el reloj** de GPIOA (si se omite, escribir en GPIOA no tiene efecto — el error más común).
2. **Configura PA6 como salida** (`MODER6 = 01`).
3. **Enciende el LED una vez** (`ODR` bit 6 = 1).
4. **Entra en un bucle infinito** que apaga el LED (`ODR` bit 6 = 0) una y otra vez.

> ⚠️ **Ojo:** tal como está escrito, **no parpadea**. Enciende el LED una sola vez (paso 3) y en el bucle sólo lo apaga, quedando apagado para siempre. Le faltan el *toggle* y los *delays*.

> 💡 **Sobre la sintaxis:** en el ensamblador de GNU los valores inmediatos llevan `#` (p.ej. `MOV R2, #0x01` y `ORR R2, R1, #EN_RCC_PTA`). Si tu ensamblador da error de sintaxis, agrega el `#` a `MOV R2, 0x01` y a `ORR R2, R1, EN_RCC_PTA`.

---
## Cómo hacerlo parpadear (blink real)

La idea: dentro del bucle, **encender → esperar → apagar → esperar**. El "esperar" (delay) es simplemente un contador que decrementa hasta cero (bucle vacío que quema ciclos de CPU).

```assembly
loop:
        /* Encender LED: ODR bit 6 = 1 */
        LDR R0, =GPIOA_BASE
        LDR R1, [R0, #GPIOA_ODR_OFFSET]
        ORR R1, R1, #(1 << 6)
        STR R1, [R0, #GPIOA_ODR_OFFSET]

        BL  delay                    // esperar

        /* Apagar LED: ODR bit 6 = 0 */
        LDR R0, =GPIOA_BASE
        LDR R1, [R0, #GPIOA_ODR_OFFSET]
        BIC R1, R1, #(1 << 6)
        STR R1, [R0, #GPIOA_ODR_OFFSET]

        BL  delay                    // esperar
        B   loop

/* Retardo por software: decrementa un contador hasta 0 */
delay:  LDR R5, =2000000             // ~ajusta este número para ver el parpadeo
d1:     SUBS R5, R5, #1              // R5 = R5 - 1 y actualiza flags
        BNE  d1                      // mientras R5 != 0, seguir contando
        BX   LR                      // volver
```

> Un `EOR` (XOR) sobre el bit 6 haría el *toggle* en una sola operación, pero para empezar es más claro el par encender/apagar explícito.

---
## Enlaces
[[Ing. Electrónica]]
[[Clase 04 - Operaciones en Assembly_Entrenamiento]]