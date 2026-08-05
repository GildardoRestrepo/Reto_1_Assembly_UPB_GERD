/* ============================================================================
 * main.s  --  Fase 1: encender UN LED (validación del toolchain)
 * ----------------------------------------------------------------------------
 * Objetivo de esta fase: comprobar el flujo completo Segger (build) ->
 * STM32CubeProgrammer (flash) -> LED encendido. Si esto funciona, el resto
 * del reto es incremental.
 *
 * Secuencia mínima para encender un LED en un pin de propósito general:
 *   1) Habilitar el reloj del puerto GPIO en RCC (si el periférico no tiene
 *      reloj, sus registros no responden).
 *   2) Configurar el pin como SALIDA (registro MODER).
 *   3) Poner el pin en alto (registro ODR).
 *
 * LED de prueba: PD0.  (Ver docs/decisiones-diseno.md -> ESTA ELECCIÓN ES TUYA)
 * ==========================================================================*/

    .syntax unified
    .cpu    cortex-m4
    .thumb

/* ---- Direcciones de registros (STM32F407, RM0090) ------------------------ */
    .equ RCC_AHB1ENR, 0x40023830   /* RCC base 0x40023800 + offset 0x30        */
    .equ GPIOD_BASE,  0x40020C00   /* base del puerto D                         */
    .equ GPIO_MODER,  0x00         /* offset del registro MODER                */
    .equ GPIO_ODR,    0x14         /* offset del registro ODR                  */

    .section .text
    .thumb_func
    .global Reset_Handler          /* exportado para que vectors.s lo encuentre */
Reset_Handler:

    /* 1) Habilitar reloj de GPIOD:  RCC_AHB1ENR |= (1 << 3)
     *    Bit 3 = GPIODEN. Leemos-modificamos-escribimos para no pisar otros bits. */
    ldr   r0, =RCC_AHB1ENR
    ldr   r1, [r0]
    orr   r1, r1, #(1 << 3)
    str   r1, [r0]

    /* 2) PD0 como salida:  MODER[1:0] = 01
     *    Cada pin ocupa 2 bits en MODER. 00=entrada, 01=salida, 10=alt, 11=analog. */
    ldr   r0, =GPIOD_BASE
    ldr   r1, [r0, #GPIO_MODER]
    bic   r1, r1, #(0b11 << 0)     /* limpiamos los 2 bits de PD0            */
    orr   r1, r1, #(0b01 << 0)     /* 01 -> salida                          */
    str   r1, [r0, #GPIO_MODER]

    /* 3) Encender el LED: ODR bit0 = 1 */
    ldr   r1, [r0, #GPIO_ODR]
    orr   r1, r1, #(1 << 0)
    str   r1, [r0, #GPIO_ODR]

    /* Fin: nos quedamos aquí para siempre (todavía no hay lógica de juego). */
loop_forever:
    b     loop_forever
