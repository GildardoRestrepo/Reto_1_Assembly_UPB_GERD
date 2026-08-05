# Configuración del proyecto en Segger Embedded Studio (bare-metal en Assembly)

> Objetivo: un proyecto que compile **solo nuestros `.s`**, con nuestra propia
> tabla de vectores en `0x08000000`, sin startup en C ni CMSIS-Driver.
> El flasheo se hace aparte con STM32CubeProgrammer.

## Paso 1 — Instalar soporte del STM32F4 (una sola vez)
`Tools → Package Manager` → buscar **"STM32F4"** → instalar el CPU Support Package.
Esto le da a SES el mapa de memoria correcto del F407.

## Paso 2 — Crear el proyecto
`File → New Project` → plantilla de ejecutable para Cortex-M / STM32.
- Target/Device: **STM32F407VE** (512 KB FLASH @ `0x08000000`, 128 KB RAM @ `0x20000000`).
- Ubicación: dentro de esta carpeta, en una subcarpeta `segger/` (para que quede en el repo).

## Paso 3 — Identificar lo que generó SES  ⬅️ CHECKPOINT
SES crea varios archivos automáticamente (típicamente: `main.c`, un startup `.s`,
un archivo de *vectors*, un *MemoryMap.xml* y un *flash_placement.xml*).
Anotar aquí la lista real para decidir qué se excluye:

- [ ] `______________________`  (¿main.c?)
- [ ] `______________________`  (¿startup .s?)
- [ ] `______________________`  (¿vectors .s?)
- [ ] `______________________`  (MemoryMap.xml)  → **CONSERVAR**
- [ ] `______________________`  (flash_placement.xml) → **CONSERVAR**

## Paso 4 — Reemplazar startup por lo nuestro
- **Excluir del build** (clic derecho → Exclude / Remove) los archivos que definan
  la tabla de vectores, el `Reset_Handler` y el `main.c` generados
  (chocarían con `src/vectors.s` y `src/main.s`).
- **Conservar** el MemoryMap y el flash_placement (dan las regiones correctas y ya
  colocan la sección `.vectors` al inicio de la FLASH).
- `Add Existing File` → agregar `../src/vectors.s` y `../src/main.s`.

## Paso 5 — Salida .hex para CubeProgrammer
En `Project → Options` buscar **"Additional Output Format"** y ponerlo en **`hex`**
(suele estar bajo Linker o Build). El `.hex` queda en `Output/<Config>/Exe/`.

## Paso 6 — Build y flash
1. `Build` en SES.
2. STM32CubeProgrammer → conectar ST-Link → cargar el `.hex` en `0x08000000` → Program.
3. Reset físico → el LED debe encender.

## Errores comunes
- *Duplicate symbol `Reset_Handler` / `.vectors`* → quedó sin excluir un archivo de
  startup de SES. Revisar Paso 4.
- *El LED no enciende pero no hay error de build* → revisar que el `.hex` se cargó en
  `0x08000000` y que el pin elegido corresponde al LED físico.
