---
tags:
  - tipo/clase
---
---
# Microprocesadores
17/07/2026

---

# Arquitectura de microprocesadores
## Harvard vs Von Neumann, `RISC` vs `CISC`
---
### Objetivos específicos
- Comparar arquitecturas, comprender similitudes y diferencias.
---
### 1. Arquitectura Von Neumann
Arquitectura más tradicional y utilizada en computadoras de propósito general. Propuesta en 1945.
Características principales:
- Instrucciones y datos comparten un mismo espacio de memoria.
- Un solo bus de dirección y un solo bus de datos.
- Acceso secuencial: No se puede leer instrucción y dato simultáneamente. 

Ventajas:
1. Simplicidad.
2. Flexibilidad.
3. Costo.
4. Universalidad.

Desventajas:
1. Cuello de botella de Von Neumann - Límite en la velocidad de procesamiento.
2. Riesgo de `sobreescritura`.
3. Menor rendimiento en aplicaciones intensivas.

Ejemplos:
1. Intel x86 (8086, 80386, Pentium, `Core i7`)
2. AMD64


### 2. Arquitectura Harvard
Propuesta en 1930 para el Mark 1.
Características principales:
- Memorias separadas (ROM y RAM) cada uno con su respectivo bus de datos y bus de direcciones.
**La mayoría de microcontroladores siguen esta arquitectura**

Ventajas
1. Mayor velocidad.
2. Seguridad.
3. Optimización. Memorias de anchos de bus diferentes aprovechados a necesidad.
4. Determinismo

Desventajas:
1. Complejidad.
2. Costo.
3. Inflexibilidad: No se puede ejecutar código desde RAM.

Ejemplos
1. Microcontroladores `PIC` de Microchip (`PIC16F`, `PIC18F`).
2. `DSP`.
3. Procesadores especializados.

### 3. Arquitectura Harvard modificada
`ARM Cortex-M`, combina lo mejor de ambas arquitecturas
Características:
1. Buses separados internamente.
2. Espacio de direcciones unificado.
3. Flexibilidad.
4. Cachés separadas.

¿Por qué `ARM` usa Harvard Modificada?
```
Flexibilidad, Optimización, 
```

### 4. Arquitectura `CISC` (Complex Instruction Set Computer)
Conjunto de instrucciones complejas de longitud variable.

Etapas:
1. Instrucciones `CISC`.
2. Unidad de control y decodificación.
3. Descomposición de instrucciones en microinstrucciones
4. Ejecución en la `CPU`.

Características:
1. Tamaño variable de instrucciones.
2. Muchos modos de direccionamiento.
3. Microprogramación.
4. El enfoque es reducir el número de instrucciones por programas

Ventajas: Orientadas al programador
1. Menos instrucciones por programa.
2. Compilador más simple.
3. Compatibilidad.

Desventajas:
1. Hardware más complejos (circuitos especializados de `ALU`).
2. Decodificación más lenta.
3. Mayor consumo de energía.
4. Pipeline complejo. 
5. Muchas instrucciones poco usadas: aprox. 20% de instrucciones abarcan el 80% del uso.

### 5. Arquitectura `RISC`
Conjunto de instrucciones reducido. Todas las instrucciones tienen la misma longitud. Cada instrucción se ejecuta un ciclo de reloj.
Etapas:
1. Búsqueda de instrucciones.
2. Decodificación y lectura de registros.
3. Ejecución en la `ALU`.
4. Acceso a memoria de datos.
5. Escritura de registros.

Ventajas:
1. Instrucciones simples.
2. Tamaño fijo.
3. Load / Store.
4. Muchos registros.
5. Pipeline muy eficiente.
6. Ejecución en un ciclo (idealmente).

Desventajas:
1. Más instrucciones por programa.
2. Compilador más complejo.
3. Código más grande.

Ejemplos de `RISC`:
1. `ARM` (`Cortex-M`, `Cortex-A`)
2. `MIPS`
3. `RISC`-V (ESP32)
4. `SPARC`
5. `PowerPC`

---
## Lista de ideas de clase
- Los perifericos son puertos.
- Perifericos mapeados a memoria.
- El compilador juega un papel muy importante en la arquitectura.

---
## Enlaces
[[Ing. Electrónica]]