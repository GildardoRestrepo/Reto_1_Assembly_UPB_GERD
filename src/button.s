/* ============================================================================
 * button.s  --  Lectura del pulsador K1 (PE3) con ANTIRREBOTE por software
 * ----------------------------------------------------------------------------
 * Expone dos rutinas globales (patrón multi-.s):
 *     button_init : enciende el reloj de GPIOE y pone PE3 como entrada con pull-up.
 *     button_read : devuelve r0 = 1 si el botón está pulsado (confirmado), 0 si no.
 *
 * K1 es ACTIVO-BAJO: un extremo del botón a GND. Con pull-up interno,
 * en reposo el pin lee 1; al pulsar, lee 0.
 *
 * Antirrebote: un botón mecánico "rebota" ~1-20 ms al cerrarse (varios 0/1
 * espurios). Estrategia: si detectamos un 0, ESPERAMOS y volvemos a leer; solo
 * si sigue en 0 lo damos por válido. Así ignoramos los rebotes rápidos.
 * ==========================================================================*/

    .syntax unified
    .cpu    cortex-m4
    .thumb

/* ---- Registros (STM32F407, RM0090) --------------------------------------- */
    .equ RCC_AHB1ENR, 0x40023830   /* habilitación de relojes del bus AHB1      */
    .equ GPIOE_BASE,  0x40021000   /* base del puerto E                         */
    .equ GPIO_PUPDR,  0x0C         /* offset PUPDR (resistencias)               */
    .equ GPIO_IDR,    0x10         /* offset IDR   (entrada, solo lectura)      */

    .equ BTN_MASK,    (1 << 3)     /* PE3 -> bit 3 en IDR                        */
    .equ DEBOUNCE_MS, 20           /* ventana de reconfirmación antirrebote      */

    .section .text

/* ---------------------------------------------------------------------------
 * button_init : reloj de GPIOE + PE3 como entrada con pull-up.
 *   Sin argumentos. Usa r0-r1 (scratch).
 * ------------------------------------------------------------------------- */
    .thumb_func
    .global button_init
button_init:
    /* 1) Reloj de GPIOE: RCC_AHB1ENR |= (1 << 4)   (bit 4 = GPIOEEN) */
    ldr   r0, =RCC_AHB1ENR
    ldr   r1, [r0]
    orr   r1, r1, #(1 << 4)
    str   r1, [r0]

    /* 2) PE3 con pull-up: PUPDR[7:6] = 01
     *    (MODER queda 00 = entrada por reset, no hace falta tocarlo). */
    ldr   r0, =GPIOE_BASE
    ldr   r1, [r0, #GPIO_PUPDR]
    bic   r1, r1, #(0b11 << 6)     /* limpia los 2 bits de PE3                  */
    orr   r1, r1, #(0b01 << 6)     /* 01 -> pull-up                            */
    str   r1, [r0, #GPIO_PUPDR]
    bx    lr

/* ---------------------------------------------------------------------------
 * button_read : ¿botón pulsado (confirmado)?  ->  r0 = 1 (sí) / 0 (no).
 *   Salida rápida si no está pulsado. Solo gasta 20 ms cuando hay candidato.
 *
 *   OJO: llama a delay_ms con 'bl', que sobrescribe lr. Como button_read es
 *   a su vez una función, guardamos SU lr en la pila (push) y retornamos con
 *   pop {pc}. Esto es el manejo de llamadas anidadas (AAPCS).
 * ------------------------------------------------------------------------- */
    .thumb_func
    .global button_read
button_read:
    push  {lr}
    ldr   r0, =GPIOE_BASE
    ldr   r1, [r0, #GPIO_IDR]
    tst   r1, #BTN_MASK            /* ¿bit PE3 = 1? -> no pulsado               */
    bne   btn_release

    movs  r0, #DEBOUNCE_MS         /* candidato: esperar la ventana de rebote   */
    bl    delay_ms
    ldr   r0, =GPIOE_BASE
    ldr   r1, [r0, #GPIO_IDR]
    tst   r1, #BTN_MASK
    bne   btn_release             /* fue rebote -> 0                           */
    movs  r0, #1                   /* sigue pulsado -> pulsación válida         */
    pop   {pc}
btn_release:
    movs  r0, #0
    pop   {pc}
