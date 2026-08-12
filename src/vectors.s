/* ============================================================================
 * vectors.s  --  Tabla de vectores mínima para Cortex-M4 (STM32F407)
 * ----------------------------------------------------------------------------
 * Al energizar/resetear, el núcleo Cortex-M lee automáticamente:
 *     0x08000000  -> valor inicial del Stack Pointer (MSP)
 *     0x08000004  -> dirección del Reset_Handler (se carga en el PC)
 *
 * Solo se declaran tablas y se referencia al Reset_Handlers
 * ==========================================================================*/

    .syntax unified
    .cpu    cortex-m4
    .thumb

    .section .vectors, "a"      /* sección "solo lectura", va al inicio de FLASH */
    .align  2                   /* alineación a 4 bytes                          */
    .global _vectors
_vectors:
    .word   0x20020000          /* [0x00] SP inicial = tope de la SRAM (128 KB)  */
    .word   Reset_Handler       /* [0x04] Reset  (definido en main.s)            */
    .word   Default_Handler     /* [0x08] NMI                                    */
    .word   Default_Handler     /* [0x0C] HardFault                              */


    .section .text
    .thumb_func
    .weak   Default_Handler
    .global Default_Handler
Default_Handler:
    b       .
