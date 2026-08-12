/* ============================================================================
 * main.s  --  Fase 4: juego "Ruleta de Precisión" (acierto / fallo / reinicio)
 * ----------------------------------------------------------------------------
 * Barrido ping-pong de un LED sobre PD0..PD7. El jugador pulsa K1 (PE3)
 * intentando acertar cuando el LED OBJETIVO (PD3, central) esté encendido.
 *   - ACIERTO -> el objetivo parpadea 3 veces y el juego reinicia.
 *   - FALLO   -> congela el LED erróneo 2 s y el juego reinicia.
 *
 * Reutiliza los módulos:
 *   systick.s : systick_init, delay_ms   (tiempos por SysTick, polling)
 *   button.s  : button_init, button_read (lectura de K1 con antirrebote)
 * ==========================================================================*/

    .syntax unified
    .cpu    cortex-m4
    .thumb

/* ---- Direcciones de registros (STM32F407, RM0090) ------------------------ */
    .equ RCC_AHB1ENR, 0x40023830   /* habilitación de reloj del bus AHB1        */
    .equ GPIOD_BASE,  0x40020C00   /* base del puerto D (LEDs)                  */
    .equ GPIO_MODER,  0x00         /* offset MODER                             */
    .equ GPIO_ODR,    0x14         /* offset ODR                               */

/* ---- Parámetros del juego ------------------------------------------------- */
    .equ STEP_MS,   50             /* velocidad del barrido (ms)               */
    .equ TARGET,    0x08           /* LED objetivo = PD3 (bit 3)               */
    .equ BLINK_MS,  200            /* on/off del parpadeo de victoria (ms)     */
    .equ BLINK_N,   3              /* número de parpadeos                      */
    .equ FREEZE_MS, 2000           /* congelamiento por fallo (2 s)            */


    .section .text
    .thumb_func
    .global Reset_Handler

Reset_Handler:

    /* 1) Reloj de GPIOD (LEDs): RCC_AHB1ENR |= (1 << 3) */
    ldr   r0, =RCC_AHB1ENR
    ldr   r1, [r0]
    orr   r1, r1, #(1 << 3)
    str   r1, [r0]

    /* 2) PD0..PD7 como salida (MODER = 0x5555 en los 16 bits bajos) */
    ldr   r0, =GPIOD_BASE
    ldr   r1, [r0, #GPIO_MODER]
    movw  r2, #0xFFFF
    bic   r1, r1, r2
    movw  r2, #0x5555
    orr   r1, r1, r2
    str   r1, [r0, #GPIO_MODER]

    /* 3) Todos los LEDs apagados al inicio (requisito del reto) */
    ldr   r5, =GPIOD_BASE          /* r5 = base de GPIOD (se usa en todo el juego) */
    movs  r1, #0
    str   r1, [r5, #GPIO_ODR]

    /* 4) Periféricos: base de tiempo y botón */
    bl    systick_init
    bl    button_init

/* ======================= BUCLE PRINCIPAL DEL JUEGO =======================
 * r4 = patrón del LED encendido ; r5 = base de GPIOD.
 * (r4/r5/r6 se conservan, delay_ms/button_read solo usan r0-r2.)      */

reiniciar:
    movs  r4, #0x01               /* arranca la partida en PD0                */

    /* ---- Ida: PD0 -> PD7 ---- */
barrido:
    str   r4, [r5, #GPIO_ODR]     /* muestra el LED actual                    */
    movs  r0, #STEP_MS
    bl    delay_ms
    bl    button_read             /* ¿K1 pulsado?          */
    cmp   r0, #1
    beq   evaluar                 /* sí -> evaluar (r4 = LED que estaba activo)*/
    lsls  r4, r4, #1
    cmp   r4, #0x100
    bne   barrido

    /* ---- Retorno: PD6 -> PD1 ---- */
    movs  r4, #0x40
inverso:
    str   r4, [r5, #GPIO_ODR]
    movs  r0, #STEP_MS
    bl    delay_ms
    bl    button_read
    cmp   r0, #1
    beq   evaluar
    lsrs  r4, r4, #1
    cmp   r4, #0x01
    bne   inverso
    b     barrido

/* ============================= EVALUACIÓN ============================= */
evaluar:
    cmp   r4, #TARGET             /* ¿el LED encendido es el objetivo (PD3)?  */
    beq   victoria

/* ---- FALLO: congela el LED erróneo 2 s y reinicia ---- */
    str   r4, [r5, #GPIO_ODR]     /* mantiene visible el LED erróneo          */
    ldr   r0, =FREEZE_MS
    bl    delay_ms
    b     reiniciar

/* ---- ACIERTO: el objetivo parpadea 3 veces y reinicia ---- */
victoria:
    movs  r6, #BLINK_N            /* contador de parpadeos                    */
v_loop:
    movs  r1, #TARGET             /* objetivo ON                             */
    str   r1, [r5, #GPIO_ODR]
    movs  r0, #BLINK_MS
    bl    delay_ms
    movs  r1, #0                  /* todo OFF                                */
    str   r1, [r5, #GPIO_ODR]
    movs  r0, #BLINK_MS
    bl    delay_ms
    subs  r6, r6, #1
    bne   v_loop
    b     reiniciar
