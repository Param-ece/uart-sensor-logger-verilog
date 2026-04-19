# UART Sensor Data Logger — Verilog

## Overview
FPGA-based UART serial communication system implemented in Verilog and simulated on Xilinx Vivado.
Reads simulated temperature sensor data (20°C–35°C) and transmits it serially via UART at 9600 baud.

## Modules
- `clk_div.v` — Clock divider (100MHz → 9600 baud)
- `uart_tx.v` — UART transmitter FSM
- `sensor_sim.v` — Simulated temperature sensor
- `top.v` — Top-level integration

## Tools
- Xilinx Vivado ML Edition
- Verilog HDL

## Status
Week 1 in progress — clock divider module
