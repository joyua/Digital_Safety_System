# Digital Safety System RTL Design Project

This repository provides the Verilog RTL implementation, verification scripts, and documentation for a **4-digit password-based digital safety system**.  
The design targets FPGA/ASIC platforms, focusing on robust user authentication, fail-safe operation, and real-time status visualization.

---

## 🧠 Project Goals

- Implement a secure 4-digit digital lock system using Verilog RTL
- Integrate all user interaction (password set/input, digit navigation, authentication) in a hardware state machine
- Ensure reliable input handling with debouncing and synchronization
- Visualize authentication and system status with 7-segment, LED, and RGB/VGA output
- Validate correctness and functional safety under exhaustive scenarios

---


## 🧩 System Architecture

| Module                    | Functionality Description                                                        |
|---------------------------|---------------------------------------------------------------------------------|
| **Digital_Safe_With_Counter** | Top-level: FSM for password set/input/check, control, and display logic       |
| **up_counter_4**          | Four-digit decimal counter, digit selection, increment/decrement                |
| **debouncer**             | Glitch/noise removal for pushbutton inputs                                      |
| **synchronizer**          | Clock-domain crossing for asynchronous inputs                                   |
| **clk_gen_25_2M**         | 125 MHz to 25.2 MHz and 100 MHz clock division                                  |
| **pattern_gen**           | Real-time RGB/VGA pattern (success/green, fail/red, idle/white)                 |
| **dec2ssd**               | BCD digit to 7-segment display code conversion                                  |
| **uart_tx**               | UART transmission of system log and error/status information                    |
| **watchdog_fsm**          | Periodic self-test and automatic reset/fail-safe logic                          |

All RTL modules are independently synthesizable and simulation-ready.

---

## 📊 Functional Overview

| Operation         | Button/Signal      | Description                                                  |
|-------------------|-------------------|--------------------------------------------------------------|
| Password Setup    | PW_set, PW_endset | Enter & store new 4-digit password via counter/slide         |
| Password Entry    | up, down, slide, OK| Digit selection and password input/confirmation              |
| Auth Check        | OK                | Compare input with stored password, trigger status logic     |
| Display Switch    | place             | Select left/right digit pair for 7-segment display           |
| User Feedback     | sled, led6_r/g, o_r/g/b_data | LEDs, RGB, and VGA output for current status        |
| UART Logging      | uart_tx           | All events, errors, and state transitions sent to PC terminal|
| Self-Diagnosis    | watchdog_fsm      | Periodic system health check and fail-safe entry on error    |

---

## 🔬 Verification & PPA Evaluation

- **Simulation**  
  - Comprehensive testbench covers password setup, input, correct/incorrect attempts, error, and edge cases
  - Waveform monitoring of internal state (pw_state), fail-safe, UART, and visual outputs (Vivado/ModelSim)
- **Synthesis (FPGA/ASIC)**  
  - Target: Xilinx Artix-7/Cyclone V, or ASIC 40nm
  - Timing, area, and power analysis available via standard synthesis tools
  - All modules designed for timing closure at >100 MHz

---

## 📁 File Structure

```text
/rtl
  ├─ Digital_Safe_With_Counter.v
  ├─ up_counter_4.v
  ├─ clk_gen_25_2M.v
  ├─ debouncer.v
  ├─ synchronizer.v
  ├─ pattern_gen.v
  ├─ dec2ssd.v
  ├─ uart_tx.v
  ├─ watchdog_fsm.v
/testbench
  └─ Digital_Safe_With_Counter_tb.v
README.md



---


## 🚀 Future Development / Expansion Plan

Planned upgrades for this system include:

- **Dual-Input Redundancy & Fail-Safe FSM**  
  Integration of dual-redundant input and advanced fail-safe mechanisms for hardware reliability.

- **UART Logging & Host Communication**  
  Enhanced real-time UART transmission of all events and errors for field maintenance and remote diagnostics.

- **Self-Diagnosis & Watchdog FSM**  
  Full-featured watchdog and health-check FSM for continuous system self-monitoring.

- **Visualization Enhancement**  
  More granular state visualization using multi-color LEDs, 7-segment, and display patterns for clear operator feedback.

> These features are designed for deployment in critical industrial, embedded, and safety-centric applications.

---

## 🧑‍💻 Author

Designed by **Changhyun Jo** (Inha University, EE)  
Contact: kil0886@naver.com  
GitHub: [github.com/joyua](https://github.com/joyua)

> “Making safety tangible — robust hardware security by pure RTL design.”


