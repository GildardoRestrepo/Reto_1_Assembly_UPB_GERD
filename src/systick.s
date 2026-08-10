/* ============================================================================
 * systick.s  --  Base de tiempo por SysTick (polling, SIN interrupciones)
 * ----------------------------------------------------------------------------
 * Expone dos rutinas globales para el resto del proyecto (patrón multi-.s):
 *     systick_init : configura SysTick para un "tick" de 1 ms.
 *     delay_ms     : espera r0 milisegundos sondeando la bandera COUNTFLAG.
 *
 * Reloj: HSI 16 MHz. Fuente de SysTick = reloj del procesador (CLKSOURCE = 1).
 *
 * Cálculo del valor de recarga (para tu documentación de tiempos):
 *     T_tick = (RELOAD + 1) / f_clk
 *     Para T_tick = 1 ms y f_clk = 16 MHz:
 *     RELOAD = f_clk * T_tick - 1 = 16e6 * 1e-3 - 1 = 15999   (= 0x3E7F)
 *
 * SysTick es un contador DESCENDENTE de 24 bits: carga RELOAD, baja hasta 0,
 * activa COUNTFLAG, recarga y repite. Máx. RELOAD = 0xFFFFFF (16 777 215).
 * ==========================================================================*/

    .syntax unified
    .cpu    cortex-m4
    .thumb

/* ---- Registros de SysTick (Cortex-M4, bloque SCS base 0xE000E010) --------- */
    .equ STK_CTRL,  0xE000E010   /* CSR : control y estado                     */
    .equ STK_LOAD,  0xE000E014   /* RVR : valor de recarga                     */
    .equ STK_VAL,   0xE000E018   /* CVR : valor actual del contador            */

    .equ RELOAD_1MS, 15999       /* <-- RETO A: verifica tú este número        */

    .section .text

/* ---------------------------------------------------------------------------
 * systick_init : deja SysTick corriendo con periodo de 1 ms.
 *   Sin argumentos. Usa r0-r1 (scratch). Retorna con bx lr.
 * ------------------------------------------------------------------------- */
    .thumb_func
    .global systick_init
systick_init:
    ldr   r0, =STK_LOAD
    ldr   r1, =RELOAD_1MS
    str   r1, [r0]                /* STK_LOAD = 15999                          */

    ldr   r0, =STK_VAL
    movs  r1, #0
    str   r1, [r0]               /* escribir cualquier valor pone el contador a 0 */

    ldr   r0, =STK_CTRL
    movs  r1, #0b101             /* bit2 CLKSOURCE=1 (proc clk) | bit0 ENABLE=1 */
    str   r1, [r0]              /* bit1 TICKINT=0 -> sin IRQ, trabajamos por sondeo */
    bx    lr

/* ---------------------------------------------------------------------------
 * delay_ms : espera (r0) milisegundos y retorna.
 *   Entrada : r0 = número de milisegundos.
 *   Usa r0-r2 (todos scratch); NO toca r4-r11, así el llamante los conserva.
 *
 *   COUNTFLAG = bit 16 de STK_CTRL. Se pone a 1 cuando el contador llega a 0,
 *   y se limpia AUTOMÁTICAMENTE al leer STK_CTRL. Cada bandera = 1 ms.
 * ------------------------------------------------------------------------- */
    .thumb_func
    .global delay_ms
delay_ms:
    ldr   r1, =STK_CTRL
delay_loop:
    cmp   r0, #0
    beq   delay_done             /* ya contamos todos los ms -> salir          */
delay_wait:
    ldr   r2, [r1]              /* leer CTRL (esta lectura limpia COUNTFLAG)   */
    tst   r2, #(1 << 16)        /* ¿COUNTFLAG activa?                          */
    beq   delay_wait           /* aún no -> seguir sondeando                   */
    subs  r0, r0, #1            /* pasó 1 ms -> descuenta                       */
    b     delay_loop
delay_done:
    bx    lr
