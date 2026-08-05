---
tags:
  - tipo/clase
---
---
# Microprocesadores
31/07/2026

---
## Módulo SysTick

No está en el datasheet [[dm00031020.pdf]] porque no es oficial de muchos fabricantes.

> Revisar concepto de **árbol de reloj** 

### Registros principales
- SysTick Control and Status Register (SYST_CSR): 
- SysTick Reload Value Register (SYST_RVR / LOAD): Valor de inicio del contador decremental
- SysTick Current Value Register (SYST_CVR / VAL): Almacena el valor actual en la cuenta

---
### Paso a paso de configuración
1. Desabilitar el temporizador: Escribir 0 en el bit `ENABLE` del `SYST_CSR` para detener cualquier conteo en curso.
2. Configurar el valor de recarga: Cantidad de registros deseados - 1.
3. Limpiar contador actual: Escribir un valor cualquiera (`0`)en `SYST_CVR`.
4. Seleccionar fuente e interrupciones: Configurar los bits `CLKSOURCE` y `TICKINT` en `SYST_CSR`.
5. Habilitar el temporizador: Escribir `1` en el `ENABLE` del `SYST_CSR` para iniciar la cuenta.


> **SysTick_Handler:** Rutina de interrupción
---
## Enlaces
[[Ing. Electrónica]]
