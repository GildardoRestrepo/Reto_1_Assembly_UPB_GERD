# Cheatsheet — Assembly ARM Thumb-2 (STM32F407)

---

Autor: Gildardo E. Restrepo
Curso: Microcontroladores
Semestre: 2026-02

---

> Referencia rápida de las instrucciones y directivas usadas en este proyecto.
> Todos los ejemplos salen del código real (`src/*.s`).

## Registros y convención de llamada (AAPCS)

| Registro | Rol |
|---|---|
| `r0`–`r3` | Argumentos y valor de retorno; "de usar y tirar" (*caller-saved*). `r0` = 1.er argumento y retorno. |
| `r4`–`r11` | Variables locales; **el llamado debe preservarlas** (*callee-saved*). Por eso las rutinas solo tocan r0–r2 y `r4`/`r5`/`r6` sobreviven. |
| `r13` (SP) | Puntero de pila (*stack pointer*). |
| `r14` (LR) | *Link Register*: dirección de retorno de la función actual. |
| `r15` (PC) | *Program Counter*: instrucción en ejecución. |

> **Banderas (flags)**: las instrucciones que terminan en `s` (`movs`, `subs`, `lsls`, `lsrs`) y `cmp`/`tst` actualizan las banderas `Z, N, C, V`. Los saltos condicionales (`beq`, `bne`) deciden según ellas.

## Directivas del ensamblador (no generan código; guían al ensamblador/linker)

| Directiva | Qué hace | Ejemplo |
|---|---|---|
| `.syntax unified` | Usa la sintaxis unificada ARM/Thumb. | `.syntax unified` |
| `.cpu cortex-m4` | Fija la CPU objetivo. | `.cpu cortex-m4` |
| `.thumb` | Genera instrucciones Thumb-2. | `.thumb` |
| `.section .x` | Coloca lo que sigue en una sección con nombre (para el linker). | `.section .vectors` |
| `.equ N, v` | Define una constante con nombre (como `#define`). | `.equ TARGET, 0x08` |
| `.global N` | Exporta el símbolo (visible para el linker y otros `.s`). | `.global Reset_Handler` |
| `.thumb_func` | Marca la etiqueta siguiente como función Thumb (pone el bit Thumb en su dirección; clave para la tabla de vectores y `bl`). | `.thumb_func` |
| `.word v` | Emite una palabra de 32 bits (se usa en la tabla de vectores). | `.word Reset_Handler` |
| `.align n` | Alinea a 2^n bytes. | `.align 2` |
| `.weak N` | Símbolo débil (se puede sobreescribir). | `.weak Default_Handler` |

## Carga, almacenamiento y movimiento

| Instrucción | Qué hace | Ejemplo del proyecto | Equivalente en C |
|---|---|---|---|
| `ldr Rd, [Rn, #off]` | Carga una palabra de memoria en `Rn+off`. | `ldr r1, [r0, #GPIO_ODR]` | `Rd = *(Rn+off)` |
| `ldr Rd, =const` | Carga una constante de 32 bits (vía *literal pool*). | `ldr r0, =GPIOD_BASE` | `Rd = const` |
| `str Rs, [Rn, #off]` | Guarda `Rs` en memoria en `Rn+off`. | `str r4, [r5, #GPIO_ODR]` | `*(Rn+off) = Rs` |
| `movs Rd, #imm` | Mueve un inmediato pequeño (y actualiza banderas). | `movs r4, #0x01` | `Rd = imm` |
| `movw Rd, #imm16` | Carga cualquier inmediato de 16 bits (0–65535). | `movw r2, #0x5555` | `Rd = imm16` |

## Operaciones lógicas y de bits

| Instrucción | Qué hace | Ejemplo del proyecto | Equivalente en C |
|---|---|---|---|
| `orr Rd, Rn, #imm` | OR bit a bit → **poner** bits. | `orr r1, r1, #(1<<3)` | `Rd = Rn \| imm` |
| `bic Rd, Rn, #imm` | AND-NOT → **limpiar** bits (máscaras). | `bic r1, r1, #(0b11<<6)` | `Rd = Rn & ~imm` |
| `tst Rn, #imm` | `Rn AND imm`, actualiza banderas y descarta el resultado (probar un bit). | `tst r1, #(1<<3)` | `if (Rn & imm)` |
| `lsls Rd, Rn, #n` | Desplaza a la **izquierda** n bits. | `lsls r4, r4, #1` | `Rd = Rn << n` |
| `lsrs Rd, Rn, #n` | Desplaza a la **derecha** n bits. | `lsrs r4, r4, #1` | `Rd = Rn >> n` |
| `subs Rd, Rn, #imm` | Resta y actualiza banderas. | `subs r6, r6, #1` | `Rd = Rn - imm` |

## Comparación y saltos (control de flujo)

| Instrucción | Qué hace | Ejemplo del proyecto | Equivalente en C |
|---|---|---|---|
| `cmp Rn, #imm` | `Rn - imm`, actualiza banderas (no guarda el resultado). | `cmp r4, #TARGET` | prepara un `if` |
| `b lbl` | Salto incondicional. | `b barrido` | `goto lbl` |
| `beq lbl` | Salta si **igual** (Z=1 tras `cmp`). | `beq victoria` | `if (a==b) goto` |
| `bne lbl` | Salta si **distinto** (Z=0). | `bne barrido` | `if (a!=b) goto` |
| `bl lbl` | **Llamada**: guarda el retorno en `LR` y salta. | `bl delay_ms` | `func()` |
| `bx lr` | **Retorno**: salta a la dirección guardada en `LR`. | `bx lr` | `return` |

## Pila y llamadas anidadas

| Instrucción | Qué hace | Ejemplo del proyecto |
|---|---|---|
| `push {regs}` | Apila registros (los guarda en la pila). | `push {lr}` |
| `pop {regs}` | Desapila; `pop {pc}` además **retorna**. | `pop {pc}` |

> **Por qué `push {lr}` en `button_read`**: al hacer `bl delay_ms`, `LR` se sobrescribe con el retorno interno. Como `button_read` es a su vez una función, guarda *su* `LR` en la pila y retorna con `pop {pc}`. Es el patrón de **llamadas anidadas**.

## Modos de direccionamiento

| Forma | Significado | Ejemplo |
|---|---|---|
| `#imm` | Inmediato (constante literal). | `movs r0, #50` |
| `Rn` | Un registro. | `orr r1, r1, r2` |
| `[Rn]` | Memoria en la dirección `Rn`. | `ldr r1, [r0]` |
| `[Rn, #off]` | Memoria en `Rn+off` (**base + offset**, como un campo de `struct`). | `ldr r1, [r0, #0x14]` |
| `=const` | Pseudo: carga una constante de 32 bits vía *literal pool*. | `ldr r0, =0x40020C00` |

## Conceptos clave

- **El sufijo `s`** (p. ej. `movs`, `lsls`, `subs`) = "actualiza banderas". Sin él, no cambian `Z/N/C/V`.
- **`bl` + `bx lr`** = el par llamada/retorno. `LR` es la "memoria" de a dónde volver.
- **`.thumb_func`** pone el bit Thumb en la dirección de la etiqueta: por eso la tabla de vectores y los `bl` saltan correctamente.
- **Base + offset** (`[Rn, #off]`) es *idéntico* a acceder a un campo de un `struct` por puntero.
