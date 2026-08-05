---
tags:
  - tipo/clase
---
---
# Microprocesadores
24/07/2026

---
## Sintaxis de Assembly

### Instrucciones básicas de movimiento
#### MOV - Mover Datos entre Registros

```assembly
.syntax unified
.global _start
.text

_start:

MOV R0, R1           ; R0 = R1 (copia contenido)
MOV R2, #42          ; R2 = 42 (valor inmediato)
MOV R3, #0xFF        ; R3 = 255 (hexadecimal)
```
**Limitaciones**: Inmediatos limitados a 8 bits + rotación o 16 bits con MOVW

#### MOVW / MOVT - Mover 16 bits

```nasm
MOVW R0, #0x1234     ; R0 = 0x00001234 (lower 16 bits)
MOVT R0, #0x5678     ; R0 = 0x56781234 (upper 16 bits)
```
**Uso**: Cargar constantes de 32 bits en dos instrucciones

#### LDR - Cargar desde Memoria

```nasm
LDR R0, =0x20000000  ; R0 = dirección 0x20000000 (pseudo-instrucción)
LDR R1, [R0]         ; R1 = contenido en dirección apuntada por R0
LDR R2, [R0, #4]     ; R2 = contenido en (R0 + 4)
LDR R3, [R0, #8]!    ; R3 = contenido en (R0 + 8), luego R0 = R0 + 8 (pre-index)
LDR R4, [R0], #4     ; R4 = contenido en R0, luego R0 = R0 + 4 (post-index)
```
#### STR - Almacenar en Memoria

```nasm
STR R1, [R0]         ; Almacenar R1 en dirección apuntada por R0
STR R2, [R0, #4]     ; Almacenar R2 en (R0 + 4)
STR R3, [R0, #8]!    ; Almacenar R3 en (R0 + 8), luego R0 = R0 + 8
```

#### LDRB / STRB - Byte (8 bits)

```nasm
LDRB R0, [R1]        ; Cargar 1 byte (8 bits) desde [R1]
STRB R2, [R3]        ; Almacenar byte bajo de R2 en [R3]
```

#### LDRH / STRH - Half-word (16 bits)

```nasm
LDRH R0, [R1]        ; Cargar 2 bytes (16 bits) desde [R1]
STRH R2, [R3]        ; Almacenar 16 bits bajos de R2 en [R3]
```
---
### Directivas de Ensamblador

#### Directivas Básicas

```nasm
.syntax unified      ; Usar sintaxis unificada ARM/Thumb
.cpu cortex-m4       ; Especificar procesador objetivo
.thumb               ; Generar código Thumb (obligatorio en Cortex-M)
```

#### Secciones

```nasm
.text                ; Sección de código (ejecutable)
.data                ; Sección de datos inicializados (RAM)
.bss                 ; Sección de datos no inicializados (RAM)
```

#### Símbolos y Etiquetas

```nasm
.global _start       ; Hacer la función _start global en todo el proyecto
.equ VALOR, 100      ; Definir constante VALOR = 100

_start:              ; Etiqueta (dirección en código)
    MOV R0, #10
    B bucle          ; Saltar a etiqueta 'bucle'

bucle:
    SUB R0, R0, #1
    CMP R0, #0
    BNE bucle        ; Si R0 != 0, saltar a 'bucle'
    B .
```

#### Datos en Memoria

```nasm
.data
variable:
    .word 0x12345678  ; 32 bits (4 bytes)
    .half 0x1234      ; 16 bits (2 bytes)
    .byte 0x12        ; 8 bits (1 byte)

string:
    .asciz "Hola"     ; String terminado en null

array:
    .word 1, 2, 3, 4, 5  ; Array de 5 elementos de 32 bits
```
---
### Operaciones

> **Objetivos:** usar instrucciones aritméticas (`ADD`, `SUB`, `MUL`, `UDIV`/`SDIV`), aplicar operaciones lógicas y de bits para configurar registros, y respetar la convención de llamada de ARM (`AAPCS`).

#### 1. Operaciones Aritméticas

**ADD - Suma**
```nasm
ADD R0, R1, R2      ; R0 = R1 + R2
ADD R0, R0, #1      ; R0 = R0 + 1 (incremento)
ADDS R0, R1, R2     ; Suma actualizando los flags (N, Z, C, V)
```

**SUB - Resta**
```nasm
SUB R0, R1, R2      ; R0 = R1 - R2
SUB R0, R0, #1      ; R0 = R0 - 1 (decremento)
SUBS R0, R1, R2     ; Resta actualizando los flags
```

**MUL - Multiplicación**
```nasm
MUL R0, R1, R2      ; R0 = R1 * R2 (32x32 = 32 bits bajos del resultado)
```

**UDIV / SDIV - División**
```nasm
UDIV R0, R1, R2     ; R0 = R1 / R2 (sin signo)
SDIV R0, R1, R2     ; R0 = R1 / R2 (con signo)
```
> **Nota:** No existe instrucción de módulo. Se calcula: `mod = dividendo - (cociente * divisor)`.
> La división por hardware (`SDIV`/`UDIV`) es una extensión opcional de `ARMv7-M`; en algunos simuladores (p.ej. CPUlator) puede no estar disponible.

**Operaciones con Flags (sufijo `S`)**
Al agregar el sufijo `S` (`ADDS`, `SUBS`, `ANDS`...) la instrucción actualiza los flags del registro de estado:

| Flag | Nombre | Significado |
| ---- | ------ | ----------- |
| `N`  | Negative | El resultado es negativo (bit 31 = 1) |
| `Z`  | Zero     | El resultado es cero |
| `C`  | Carry    | Hubo acarreo / préstamo |
| `V`  | oVerflow | Desbordamiento en aritmética con signo |

```nasm
MOV  R0, #0xFFFFFFFF ; R0 = -1 (con signo) o máximo (sin signo)
ADDS R0, R0, #1      ; R0 = 0 -> Z=1 (cero), C=1 (acarreo)
```

---
#### 2. Operaciones Lógicas (Máscaras)

La idea clave: usar una **máscara** (un patrón de bits) para modificar únicamente los bits que nos interesan **sin alterar los demás**. Este es el patrón fundamental para configurar periféricos.

**AND - Y lógico → leer / aislar / forzar a 0**
```nasm
AND R0, R1, R2      ; R0 = R1 & R2 (bit a bit)
AND R0, R0, #0x0F   ; Conservar sólo el nibble bajo (bits 0-3), el resto a 0
```
> Máscara con `1` = conservar el bit, `0` = apagarlo. Es como un esténcil: oculta lo que no interesa y deja ver sólo lo necesario.

**ORR - O lógico → poner bits a 1**
```nasm
ORR R0, R1, R2      ; R0 = R1 | R2
ORR R0, R0, #0x01   ; Poner el bit 0 a 1
```
> Máscara con `1` = encender el bit, `0` = dejarlo igual. Un interruptor de encendido selectivo.

**EOR - XOR lógico → invertir / toggle**
```nasm
EOR R0, R1, R2      ; R0 = R1 ^ R2
EOR R0, R0, R0      ; R0 = 0 (forma eficiente de limpiar un registro)
```
> Máscara con `1` = invertir el bit (0→1, 1→0), `0` = dejarlo igual. Ideal para hacer *toggle* (p.ej. parpadear un LED).

**BIC - Bit Clear (AND NOT) → poner bits a 0**
```nasm
BIC R0, R1, R2      ; R0 = R1 & ~R2 (limpia los bits marcados en R2)
BIC R0, R0, #0x01   ; Limpiar el bit 0 (ponerlo a 0)
```
> A diferencia de `AND` (donde el `1` conserva), en `BIC` el `1` de la máscara indica **qué borrar**. Es la goma de borrar sobre casillas específicas.

**MVN - Move NOT → complemento**
```nasm
MVN R0, R1          ; R0 = ~R1 (invierte todos los bits del origen)
```
> Como un `MOV`, pero aplica `NOT` bit a bit antes de guardar.

**Resumen de máscaras:**

| Quiero...              | Instrucción | Máscara con `1` en... |
| ---------------------- | ----------- | --------------------- |
| Poner bits a **1**     | `ORR`       | los bits a encender   |
| Poner bits a **0**     | `BIC`       | los bits a apagar     |
| **Invertir** bits      | `EOR`       | los bits a alternar   |
| **Leer/aislar** bits   | `AND`       | los bits a conservar  |

---
#### 3. Operaciones de Desplazamiento (Shifts)

**LSL - Logical Shift Left** (desplazamiento lógico a la izquierda)
```nasm
LSL R0, R1, #2      ; R0 = R1 << 2 (equivale a multiplicar por 4)
```

**LSR - Logical Shift Right** (desplazamiento lógico a la derecha)
```nasm
LSR R0, R1, #2      ; R0 = R1 >> 2 (dividir por 4, sin signo; entran 0 por la izquierda)
```

**ASR - Arithmetic Shift Right** (desplazamiento aritmético a la derecha)
```nasm
ASR R0, R1, #2      ; R0 = R1 >> 2 (dividir por 4 preservando el signo; replica el bit 31)
```

**ROR - Rotate Right** (rotación a la derecha)
```nasm
ROR R0, R1, #4      ; Rota R1 a la derecha 4 bits (los bits que salen reentran por la izquierda)
```

| Operación | Uso típico                   | Ejemplo               |
| --------- | ---------------------------- | --------------------- |
| `LSL`     | Multiplicar por 2^n          | `LSL R0, R0, #3` → ×8 |
| `LSR`     | Dividir por 2^n (sin signo)  | `LSR R0, R0, #2` → /4 |
| `ASR`     | Dividir por 2^n (con signo)  | `ASR R0, R0, #1` → /2 |
| `ROR`     | Rotación de bits             | Cifrado, checksum     |

> **Truco potente:** el shift se puede combinar dentro de otra instrucción (operando desplazado):
> `ORR R2, R1, R3, LSL #6` → primero calcula `R3 << 6` y luego hace el `OR`. Esto se usa muchísimo para colocar un valor en la posición de un bit concreto (ver Clase 05).

---
#### 4. Aplicación: Configuración de un Registro (patrón `read-modify-write`)

Configurar `PTA6` como salida sin tocar los demás pines. En `GPIOA_MODER` cada pin usa **2 bits**, así que el pin 6 son los bits **12-13**, y queremos dejarlos en `01` (salida):

```nasm
LDR R0, =0x40020000     ; Base de GPIOA
LDR R1, [R0, #0]        ; 1) LEER el MODER actual

BIC R1, R1, #(0b11 << 12) ; 2) MODIFICAR: limpiar bits 12-13 (dejarlos en 00)
ORR R1, R1, #(0b01 << 12) ;    y poner 01 en esos bits

STR R1, [R0, #0]        ; 3) ESCRIBIR de vuelta
```
**Patrón general (grábatelo, es la base de todo el curso):**
1. `LDR` → **leer** el valor actual del registro.
2. `BIC` → **limpiar** los bits del campo (máscara de 1s).
3. `ORR` → **establecer** el valor deseado.
4. `STR` → **escribir** de vuelta.

---
#### 5. Convención de Llamada (AAPCS)

*ARM Architecture Procedure Call Standard* — reglas para que las funciones sean compatibles entre sí:

- **R0-R3:** argumentos y valor de retorno. `R0` = 1er argumento y retorno. *No se preservan* (caller-saved).
- **R4-R11:** registros preservados (*callee-saved*). Si una función los usa, debe hacer `PUSH` al entrar y `POP` al salir.
- **R12 (IP):** temporal, no se preserva.
- **SP (R13):** debe preservarse y quedar alineado a 8 bytes.
- **LR (R14):** dirección de retorno (`BX LR` para volver).

**Función simple:**
```nasm
; int sumar(int a, int b) -> a + b   (R0=a, R1=b, retorno en R0)
sumar:
    ADD R0, R0, R1      ; R0 = a + b
    BX  LR              ; retornar

main:
    MOV R0, #10
    MOV R1, #20
    BL  sumar           ; llama a la función; LR = dirección de retorno
    ; aquí R0 = 30
```

**Función que usa registros preservados (stack):**
```nasm
; multiplica R0 por 3
multiplicar_por_tres:
    PUSH {R4, LR}       ; preservar R4 y LR
    MOV  R4, R0         ; R4 = valor original
    LSL  R1, R0, #1     ; R1 = R0 * 2
    ADD  R0, R1, R4     ; R0 = (R0*2) + R0 = R0*3
    POP  {R4, PC}       ; restaurar R4 y retornar (PC = LR guardado)
```

---
### Ejercicios prácticos

**Ejercicio 1 — Calculadora básica**
Calcular `resultado = (a + b) * c / d` con `a=10, b=5, c=3, d=3` (resultado = 15). `R0` debe contener el resultado final.
```nasm
.syntax unified
.text
.global main
main:
    MOV R0, #10         ; a
    MOV R1, #5          ; b
    MOV R2, #3          ; c
    MOV R3, #3          ; d

    ; Tu código aquí (R0 = resultado)

    B .
```

**Ejercicio 2 — Función reutilizable `maximo(a, b)`**
Retornar el mayor de dos números aplicando `AAPCS`.
```nasm
; Entrada: R0 = a, R1 = b   |   Salida: R0 = max(a, b)
maximo:
    ; Tu código aquí
    BX LR

main:
    MOV R0, #15
    MOV R1, #20
    BL  maximo          ; R0 debe quedar en 20
    B .
```

**Ejercicio 3 — Multiplicar por 5 sin usar `MUL`**
Pista: `x*5 = (x<<2) + x`.

---
### Quiz de repaso (Sesión 5)
1. ¿Qué hace `LSL R0, R0, #2`?
2. ¿Cuál es la diferencia entre `UDIV` y `SDIV`?
3. ¿Cómo se limpia el bit 3 de un registro sin afectar los demás bits?
4. ¿Qué registros deben preservarse en una función según `AAPCS`?
5. Escribe código que multiplique `R0` por 5 sin usar `MUL`.

---
## Enlaces
[[Ing. Electrónica]]
[[Clase 05 - Configurar un GPIO]]