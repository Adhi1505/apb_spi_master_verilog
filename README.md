# apb_spi_master_verilog
APB-Based SPI Master IP Core (Verilog)

A synthesizable APB (Advanced Peripheral Bus) compliant SPI Master IP Core designed in Verilog HDL.
This project implements a modular, configurable, and resource-efficient SPI Master controller featuring a complete APB register interface, programmable baud-rate generator, shift register architecture, slave-select logic, and full waveform + synthesis verification.

🚀 1. Features

✔️ Fully APB Protocol Compliant (AMBA 2.0)

✔️ Complete SPI Master functionality

✔️ Configurable Baud Rate (programmable divider register)

✔️ Supports CPOL/CPHA SPI modes

✔️ 8-bit Shift Register (parallel ↔ serial conversion)

✔️ Multi-slave selection through SS control

✔️ Full simulation waveforms for every sub-block

✔️ Synthesis reports (timing, area, power)

✔️ Clean, reusable, hierarchical RTL structure

🧱 2. Architecture Overview
Top-Level Components

As described in Section 2 of the project report:

APB Slave Interface

Baud Rate Generator

Shift Register

SPI Slave Control Select

The complete system connects an APB-based processor to SPI slave devices through register-based configuration and master-controlled data transfer.

📁 3. Repository Structure 

APB-SPI-Master/
│── src/
│    ├── apb_slave_interface.v
│    ├── baud_rate_generator.v
│    ├── shift_register.v
│    ├── spi_slave_control_select.v
│    └── spi_master_top.v
│
│── testbench/
│    ├── tb_apb_slave_interface.v
│    ├── tb_baud_rate_generator.v
│    ├── tb_shift_register.v
│    ├── tb_spi_slave_control.v
│    └── tb_spi_master_top.v
│
│── sim/
│    ├── waveform_apb.png
│    ├── waveform_baud.png
│    ├── waveform_shiftreg.png
│    ├── waveform_slave_select.png
│    └── waveform_top.png
│
│── docs/
│    ├── APB.pdf
│    ├── block_diagram.png
│    ├── netlist_apb.png
│    ├── netlist_baud.png
│    ├── netlist_shift.png
│    ├── netlist_slave_select.png
│
└── README.md

🔧 4. APB Register Map

| Address | Register  | Access | Description          |
| ------- | --------- | ------ | -------------------- |
| 0x00    | CONTROL   | R/W    | SPI Control Register |
| 0x04    | STATUS    | R      | SPI Status Register  |
| 0x08    | DATA      | R/W    | SPI Data Register    |
| 0x0C    | BAUD_DIV  | R/W    | Baud Rate Divisor    |
| 0x10    | SLAVE_SEL | R/W    | Slave Select Control |


🧩 5. Sub-Block Descriptions
5.1 APB Slave Interface

Handles all APB read/write operations and maps APB addresses to internal registers.

Responsibilities

APB protocol compliance (PSEL, PENABLE, PWRITE cycles)

Register decoding (CONTROL / STATUS / DATA / BAUD_DIV / SLAVE_SEL)

PRDATA generation during APB reads

Ready signal (PREADY) and error reporting (PSLVERR)

Outputs

Register updates on writes

Correct PRDATA on reads

write_en and read_en signals for sub-blocks

5.2 Baud Rate Generator

Generates SCLK using a programmable clock divider.

Key Features

Configurable baud rate through BAUD_DIV

Flag signals (flag_low / flag_high) for shift timing

Supports CPOL and CPHA modes

Output

SPI Clock (SCLK)

Toggle timing flags for the shift register

5.3 Shift Register

Manages parallel-to-serial and serial-to-parallel SPI data transfer.

Capabilities

8-bit parallel load and shift

Bidirectional data flow (MOSI/MISO)

MSB-first or LSB-first operation

Controlled by timing flags from baud generator

5.4 SPI Slave Control Select

Enables communication with multiple SPI slaves.

Features

Multi-slave selection via SLAVE_SEL register

Generates active-low SS signals

TIP (Transfer In Progress) flag

📊 6. Simulation Results

This project includes complete simulation waveforms for:

APB transactions

Baud rate clock generation

Shift register behavior

Slave select activation

Full SPI Master transfer sequence

🏗️ 7. Synthesis & Implementation Results

7.1 Resource Utilization

| Resource | Used | Available | Utilization |
| -------- | ---- | --------- | ----------- |
| LUTs     | 124  | 17600     | 0.70%       |
| FFs      | 89   | 35200     | 0.25%       |
| BRAM     | 0    | 60        | 0%          |
| DSP      | 0    | 80        | 0%          |
| IO Pins  | 18   | 200       | 9%          |

7.2 Timing Analysis

| Parameter  | Value     | Target  | Status |
| ---------- | --------- | ------- | ------ |
| Setup Time | 2.45 ns   | 10 ns   | PASS   |
| Hold Time  | 0.12 ns   | 0 ns    | PASS   |
| Clock-to-Q | 1.89 ns   | 5 ns    | PASS   |
| Max Freq   | 156.2 MHz | 100 MHz | PASS   |

7.3 Power Analysis

| Component     | Value      | Percentage |
| ------------- | ---------- | ---------- |
| Static Power  | 45.2 mW    | 15.1%      |
| Dynamic Power | 254.8 mW   | 84.9%      |
| **Total**     | **300 mW** | **100%**   |

7.4 Area Report

| Module              | Area (µm²) | Percentage |
| ------------------- | ---------- | ---------- |
| APB Slave Interface | 1250       | 35.7%      |
| Baud Gen            | 890        | 25.4%      |
| Shift Register      | 1120       | 32.0%      |
| Slave Select        | 240        | 6.9%       |
| **Total**           | **3500**   | **100%**   |

📝 8. Conclusion

This APB-based SPI Master IP Core is a fully verified, modular, synthesizable design suitable for:

FPGA/SoC integrations

Microcontroller-based communication systems

SPI sensor/actuator interfacing

Digital communication systems

Embedded and VLSI design workflows

The low area, clean architecture, and full compliance with APB and SPI standards make this IP core production-ready and highly reusable.

📎 9. Documentation

The full project report is included as:

https://drive.google.com/file/d/1n3DtbnRhrhafKj46Goe1mbaUBdlYarD2/view?usp=sharing

It contains detailed architecture diagrams, waveforms, synthesized netlists, and design analysis.

 Author-

Adhithyan Pillai








