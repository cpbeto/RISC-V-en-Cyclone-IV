# test-asm-loop

## Objetivos

 - Compilar PicoRV32 y ejecutar en Verilator.
 - Implementar una RAM como un array en Verilog.
 - Ejecutar un loop trivial en assembly.

## Desarrollo

El programa es ensamblado a binario crudo y cargado en la RAM mediante el método `$readmemh`.

El CPU ejecuta el loop infinito y desde el SOC de Verilog podemos imprimir usando `$display`:
 - contador de ciclos;
 - actividad de la memoria.

### Instrucciones

Compilación y linkeo

```bash
riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -Ttext=0x0 loop.S -o loop.elf
```

Verificar ELF
```bash
riscv64-unknown-elf-readelf -h loop.elf
```

Traducir ELF a binario compatible con Verilog

```bash
riscv64-unknown-elf-objcopy -O verilog --verilog-data-width=1 loop.elf loop.hex
```

Compilar SOC y testbench de Verilator

```bash
verilator --cc soc.v verilog_ram.v ../picorv32/picorv32.v --exe ./testbench.cpp -Wno-fatal
make -C obj_dir -f Vsoc.mk
```

Ejecutar simulación

```bash
./out/Vsoc
```

## Resultados

```bash
[C8] FETCH addr=00000000 data=00000013
[C12] FETCH addr=00000004 data=00000013
[C13] RETIRE PC=00000000
[C16] FETCH addr=00000008 data=ff9ff06f
[C17] RETIRE PC=00000000
[C19] RETIRE PC=00000000
```

## TODO

 - Explicar flags `riscv64-unknown-elf-gcc`
 - Explicar atributos de `riscv64-unknown-elf-readelf`
 - Explicar `riscv64-unknown-elf-objcopy` y formato de Verilog
 - Explicar funcionamiento de Verilator
 - Explicar output de la simulación y ciclo de fetch - ejecución - retiro, etc.
   - ¿Por qué el PC siempre es 0?