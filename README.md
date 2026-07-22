# RISC-V CPU Architecture in VHDL

A pipelined RISC-V CPU architecture designed and implemented in VHDL. The processor executes basic RISC-V instructions and computes the Fibonacci Series as a final verification test. Results can be visualized via the 7-segment LCD displays on a Nexys4 DDR board or inspected in simulation.

---

## 1. Project Overview

The primary goal of this project is to model a classical 5-stage RISC-V CPU in VHDL. To verify functional correctness, a Fibonacci Series algorithm was implemented in assembly to test branch logic, arithmetic operations, and memory writes. 

The project supports two main execution modes:
* **Simulation Mode:** Board-independent simulations (commit `c7af5a0`).
* **FPGA Implementation Mode:** Board-specific code including top-level processes for driving 7-segment displays and handling board push buttons (latest commit).

---

## 2. Pipeline Architecture & Stage Structure

The CPU is structured into a classical 5-stage pipeline, alongside a dedicated Control Unit.

### 2.1 Instruction Fetch (IF)
* Interfaces with Instruction Memory via clock (`clk`) and Program Counter (`pc`) signals to output instructions.
* Uses a `load_enable` signal from the Control Unit to update the Program Counter.
* Accepts feedback signals (`alu_result` and `branch`) from later pipeline stages to update execution flow.

### 2.2 Control Unit (CU)
* Determines when the next instruction can be fetched by updating the `load_enable` signal (set to `1` every two clock cycles to allow signal propagation).
* Analyzes instructions to generate register and memory write enables (`write_enable_register`, `write_enable_memory`) that forward down the pipeline.
* Operates in parallel with the Instruction Decode stage.

### 2.3 Instruction Decode (ID)
* Decodes the instruction using `funct3`, `funct7`, and `opcode` fields to set control signals for downstream stages.
* Extracts immediate values (`immediate_out`) and destination register addresses (`dest_register`) from the instruction.
* Reads source registers (`rs1`, `rs2`) from Register Memory (`read_register_1`, `read_register_2`).
* Receives feedback write signals (`write_value`, `write_address`, `write_enable`) from the Write Back stage to update register values.

### 2.4 Instruction Execute (EX)
* Features an Arithmetic Logic Unit (ALU) and a Comparator component.
* Uses multiplexers (`a_sel`, `b_sel`) to select ALU inputs between `curr_pc`, `rs1_value`, `immediate`, and `rs2_value`.
* Evaluates branch conditions using the Comparator and generates `branch_condition`.
* Feeds `alu_result` and `branch_condition` back to the IF stage for conditional jumps.

### 2.5 Memory Access (MEM)
* Handles read and write operations to Data Memory (RAM).
* Reads memory continuously every two clock cycles unless `memory_write_enable` is active.
* Forwards pipeline values (`alu_result`, destination registers, and write signals) to the next stage.

### 2.6 Write Back (WB)
* Outputs destination register addresses and values to be fed back into the Instruction Decode stage.
* Finalizes register updates for completed instructions.

---

## 3. Target Hardware (Nexys4 DDR Board)

The hardware implementation targets the **Nexys4 DDR Artix-7 FPGA**.

* **7-Segment Display (8 Digits):** Displays output data such as the incrementing Fibonacci Series, fetched instructions, or the Program Counter. Assembly code was tailored to store numbers in the same RAM register to stream them sequentially to the display.
* **Central Button (BTNC / N17):** Functions as the CPU system reset button. LED `H17` illuminates while the button is pressed.
* **Clock LED (K15):** Mirrors the active CPU clock signal.
* **Display Selection Switches (`V10`, `U11`, `U12`):**
  * `V10`: Selects the Program Counter for display.
  * `U11`: Selects the fetched instruction for display.
  * `U12`: Selects the Fibonacci Series output for display.
* **Clock Rate Switches (`J15`, `L16`):**
  * Set `J15 = 1` for a 1 Hz clock rate.
  * Set `L16 = 1` for a 100 Hz clock rate.
  * All other switch combinations default to a 100 MHz clock rate.

---

## 4. Setup, Installation & Usage

### 4.1 Prerequisites
* A VHDL simulation tool (e.g., Vivado Simulator, ModelSim).
* Xilinx Vivado (for FPGA synthesis and implementation).
* Nexys4 DDR Artix-7 FPGA board (optional for physical deployment).

### 4.2 Simulation Setup (Board-Independent)
1. Clone the repository and checkout commit `c7af5a0`:
   ```bash
   git clone [https://github.com/IGINOI/RISC-V_CPU.git](https://github.com/IGINOI/RISC-V_CPU.git)
   cd RISC-V_CPU
   git checkout c7af5a0
   ```
2. Load all VHDL source files into your simulation tool.
3. Run the top-level testbench to inspect pipeline waveforms.

### 4.3 FPGA Implementation (Nexys4 DDR)
1. Clone the repository and use the latest commit on the main branch:
   ```bash
   git clone [https://github.com/IGINOI/RISC-V_CPU.git](https://github.com/IGINOI/RISC-V_CPU.git)
   cd RISC-V_CPU
   ```
2. Open Vivado and import all VHDL source files along with the provided Nexys4 DDR constraint file (`.xdc`).
3. Run **Synthesis**, **Implementation**, and **Generate Bitstream**.
4. Program the Nexys4 DDR board via Hardware Manager.
5. **Operation:**
   * Select the desired clock speed using switches `J15` and `L16`.
   * Select display mode using switch `V10` (PC), `U11` (Instruction), or `U12` (Fibonacci).
   * Press and hold the central button **BTNC (N17)** for a couple of seconds to properly reset the CPU pipeline.

---

## 5. Verification & Final Results

### 5.1 Addition Instruction Test
Simulation was conducted executing `addi x3, x4, 5` to verify pipeline forwarding and register writing:
* **IF Stage:** Instruction is fetched when `load_enable` goes high.
* **ID Stage:** Decodes operands `rs1` and immediate value `5`.
* **EX Stage:** Signals `a_sel` and `b_sel` select correct operands, computing the result on the ALU.
* **WB Stage:** The computed result (`12`) is written back to register `x3`.

### 5.2 Fibonacci Series Test
A loop program was tested to verify conditional branching and data storage:
* **Branch Verification:** The `branch_cond` signal fires periodically, coinciding with RAM write operations.
* **Memory Integrity:** Initial value `0` is written prior to loop execution without triggering branches. Subsequent numbers of the Fibonacci Series are calculated and sequentially written to Data Memory as intended.