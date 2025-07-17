# MIPS MCU SoC on FPGA

##  Project Goal

Design and implement a MIPS-based single-cycle CPU core with memory-mapped peripherals on an FPGA.

The system includes:
- MIPS32 single-cycle CPU (pipelined in future) 
- Instruction and data memory (Harvard architecture)
- Memory-mapped GPIO
- Timer with compare capability
- Interrupt controller
- FIR filter hardware accelerator
- UART peripheral

Target FPGA: DE10-Standard (Cyclone V)
