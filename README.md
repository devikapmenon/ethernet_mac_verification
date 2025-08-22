Ethernet MAC Verification

[![Build](https://img.shields.io/badge/build-verilator-blue.svg)]()
[![SystemVerilog](https://img.shields.io/badge/code-SystemVerilog-orange.svg)]()
[![Made with ❤️ by Devika](https://img.shields.io/badge/made%20with-%E2%9D%A4-red.svg)]()

---

Overview  
This project implements and verifies an **Ethernet Media Access Controller (MAC)** using **SystemVerilog RTL** and **Verilator**.  
It covers **frame transmission, reception, and CRC32 error detection**, making it a solid foundation for learning digital design, verification, and networking hardware.  

---

Features
- 🔹 **SystemVerilog RTL Design**
  - `ethernet_mac.sv` – Top-level MAC module  
  - `mac_tx.sv` – Transmission logic  
  - `mac_rx.sv` – Reception logic  
  - `crc32_eth.sv` – CRC32 calculation  

- 🔹 **Testbench**
  - `tb_top.sv` – Self-checking testbench  
  - `sim_main.cpp` – Verilator C++ driver  

- 🔹 **Verification**
  - Cycle-accurate simulation with Verilator  
  - Waveform dump (`.vcd`) for GTKWave analysis  

---

Getting Started  

### 🔧 Prerequisites
- [Verilator](https://verilator.org/) (>= 5.x)  
- Make, GCC/Clang  
- [GTKWave](http://gtkwave.sourceforge.net/) (for waveform viewing)  
