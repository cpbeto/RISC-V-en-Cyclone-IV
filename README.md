# RISC-V-en-Cyclone-IV
Implementación de **PicoRV32** en una FPGA **Cyclone IV**.

Proyecto de pregrado para la materia **Organización del Computador 2** de la carrera **Licenciatura en Ciencias de la Computación** del [Departamento de Computación (FCEN - UBA)](https://www.dc.uba.ar/).

## Objetivos
- Un softcore RISC-V implementado y funcionando en una FPGA.
  - Comunicación UART con la PC.
  - Interacción botón/LED.
  - Benchmark (CoreMark).
- Reporte técnico.

## Dependencias

```bash
# Quartus Lite (soporte para Cyclone IV)
# Verilator
sudo apt install verilator

# RISC-V toolchain
sudo apt install gcc-riscv64-unknown-elf

# Clonar repositorio
git clone ...
```

## Hoja de ruta
### Semana 1
- Realizar el *survey* preliminar de softcores y módulos RISC-V, así como las FPGA disponibles en el mercado.
- Análisis del softcore picoRV32.
- Simular y verificar el softcore en la PC.

### Semana 2
- Preparar la el proyecto de Quartus.
- Preparar el despliegue sobre la placa de desarrollo.

### Semana 3
- Desplegar el sistema a la placa FPGA.
  - Probar la interacción botón/LED.
  - Probar la comunicación UART.
  - Opcionalmente probar interrupciones y comunicación SPI.
- Correr el benchmark CoreMark.

### Semana 4
- Redactar reporte técnico.
