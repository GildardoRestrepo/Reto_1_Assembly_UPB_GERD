/* ============================================================================
 * main.s  --  Fase 4: Lógica de juego (acierto / fallo / reinicio)
 * ----------------------------------------------------------------------------
 * Un único LED encendido a la vez, desplazándose de PD0 hacia PD7 para luego rebotar.
 * El tiempo entre pasos es CONSTANTE y lo da SysTick por sondeo.
 *
 * Hardware: 8 columnas de la matriz LED 8x8 -> PD0..PD7 (una fila a GND).
 * Como solo hay un LED encendido a la vez, escribir el patrón completo en ODR
 * enciende el actual y apaga los demás.
 * ==========================================================================*/

    .syntax unified
    .cpu    cortex-m4
    .thumb

/* ---- Direcciones de registros (STM32F407, RM0090) ------------------------ */
    .equ RCC_AHB1ENR, 0x40023830   /* habilitación de reloj del bus AHB1        */
    .equ GPIOD_BASE,  0x40020C00   /* base del puerto D                         */
    .equ GPIO_MODER,  0x00         /* offset MODER (modo de cada pin)           */
    .equ GPIO_ODR,    0x14         /* offset ODR   (salida de datos)            */

    .equ STEP_MS, 50              /* <-- RETO B: velocidad del barrido (ms)    */

/* systick_init y delay_ms viven en systick.s; el linker resuelve el 'bl'.     */

    .section .text
    .thumb_func
    .global Reset_Handler          /* exportado para que vectors.s lo encuentre */
Reset_Handler:

    /* 1) Reloj de GPIOD: RCC_AHB1ENR |= (1 << 3)  (bit 3 = GPIODEN) */
    ldr   r0, =RCC_AHB1ENR
    ldr   r1, [r0]
    orr   r1, r1, #(1 << 3)
    str   r1, [r0]

    /* 2) PD0..PD7 como SALIDA: 8 campos de 2 bits = 01 -> patrón 0x5555
     *    en los 16 bits bajos de MODER. Leer-modificar-escribir para no tocar
     *    PD8..PD15. (movw carga un inmediato de 16 bits que 'bic'/'orr' no encajan.) */
    ldr   r0, =GPIOD_BASE
    ldr   r1, [r0, #GPIO_MODER]
    movw  r2, #0xFFFF              /* máscara de los 16 bits bajos (PD0..PD7)   */
    bic   r1, r1, r2              /* limpia el modo de esos 8 pines            */
    movw  r2, #0x5555             /* 01 (salida) en cada uno de los 8 pines    */
    orr   r1, r1, r2
    str   r1, [r0, #GPIO_MODER]

    /* 3) Arrancar la base de tiempo (systick.s) */
    bl    systick_init


/* 4) Barrido: bit caminante sobre PD0..PD7 con rebote
     *    r4 = patrón del LED encendido ; r5 = base de GPIOD (se conservan
     *    porque delay_ms solo usa r0-r2). */
    ldr   r5, =GPIOD_BASE
    movs  r4, #0x01               /* empieza en PD0                            */
barrido:
    str   r4, [r5, #GPIO_ODR]     /* enciende el LED actual, apaga los demás   */
    movs  r0, #STEP_MS
    bl    delay_ms                /* espera constante por SysTick              */
    lsls  r4, r4, #1              /* desplaza el bit -> siguiente LED          */
    cmp   r4, #0x100              /* ¿ya pasó de PD7 (0x80)?                    */
    bne   barrido
    movs  r4, #0x40               /* sí -> reinicia el ciclo en PD6            */
inverso:
    str   r4, [r5, #GPIO_ODR]
    movs  r0, #STEP_MS
    bl    delay_ms
    lsrs  r4, r4, #1         /* desplaza a la DERECHA -> LED anterior        */
    cmp   r4, #0x01          /* ¿llegó a PD0?                                */
    bne   inverso            /* no -> sigue bajando                          */
    b     barrido            /* sí -> r4=0x01; el 'barrido' mostrará PD0     */