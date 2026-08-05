/* ============================================================================
 * vectors.s  --  Tabla de vectores mínima para Cortex-M4 (STM32F407)
 * ----------------------------------------------------------------------------
 * Al energizar/resetear, el núcleo Cortex-M lee automáticamente:
 *     0x08000000  -> valor inicial del Stack Pointer (MSP)
 *     0x08000004  -> dirección del Reset_Handler (se carga en el PC)
 *
 * Esta tabla DEBE quedar al inicio de la memoria FLASH (0x08000000). Eso lo
 * garantiza el linker colocando la sección ".vectors" en primer lugar.
 *
 * Fíjate en la modularidad: aquí solo declaramos la tabla y referenciamos
 * "Reset_Handler", que está definido en OTRO archivo (main.s). El linker une
 * ambos gracias a la directiva .global. Ese es el patrón multi-.s del proyecto.
 * ==========================================================================*/

    .syntax unified
    .cpu    cortex-m4
    .thumb

    .section .vectors, "a"      /* sección "solo lectura", va al inicio de FLASH */
    .align  2                   /* alineación a 4 bytes                          */
    .global __vectors
__vectors:
    .word   0x20020000          /* [0x00] SP inicial = tope de la SRAM (128 KB)  */
    .word   Reset_Handler       /* [0x04] Reset  (definido en main.s)            */
    .word   Default_Handler     /* [0x08] NMI                                    */
    .word   Default_Handler     /* [0x0C] HardFault                              */
    /* Por ahora basta con esto para arrancar. Se ampliará si usamos más excepciones. */

/* Manejador por defecto: si algo inesperado ocurre, quedamos en un bucle
 * infinito (útil para depurar: si la placa "se cuelga aquí", hubo un fault). */
    .section .text
    .thumb_func
    .weak   Default_Handler
    .global Default_Handler
Default_Handler:
    b       .
