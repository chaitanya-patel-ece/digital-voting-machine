# 🗳️ Digital Voting Machine — Basys 3 FPGA

A fully functional **Digital Voting Machine** implemented in Verilog and deployed on the **Digilent Basys 3 FPGA board** (Artix-7 XC7A35T-1CPG236C).

Voters can select a **political party** and a **candidate** using push buttons and switches, cast their vote, and view live results — all on the onboard 7-segment display and LEDs.

---

## 📁 Repository Structure

```
digital-voting-machine/
│
├── src/
│   └── digital_voting_machine.v      # Main Verilog design + debounce module
│
├── constraints/
│   └── digital_voting_machine.xdc    # Basys 3 pin constraints file
│
├── sim/
│   └── tb_digital_voting_machine.v   # Testbench for simulation
│
├── docs/
│   └── user_guide.md                 # How to use the voting machine
│
└── README.md                         # This file
```

---

## 🔧 Hardware Requirements

| Item | Details |
|------|---------|
| **Board** | Digilent Basys 3 |
| **FPGA** | Artix-7 XC7A35T-1CPG236C |
| **Tool** | Xilinx Vivado Design Suite (2020.1 or later) |
| **Clock** | 100 MHz onboard oscillator |
| **Interface** | USB-JTAG (onboard programmer) |

---

## 🗂️ Project Features

- ✅ 3 Political Parties (P1, P2, P3)
- ✅ 2 Candidates per Party = **6 total voting slots**
- ✅ Vote count up to **9,999 per candidate**
- ✅ Button debouncing (20ms) — prevents accidental double votes
- ✅ Invalid vote detection (wrong switch combo)
- ✅ Live result display on 7-segment
- ✅ LED status indicators for every action
- ✅ Admin reset functionality

---

## 🎮 Controls

### Push Buttons

| Button | Location | Function |
|--------|----------|----------|
| **BTNC** | Center | ✅ Cast Vote |
| **BTNU** | Up | 🔼 Party UP (P1→P2→P3→P1) |
| **BTND** | Down | 🔽 Party DOWN (P1→P3→P2→P1) |
| **BTNL** | Left | 🔍 View Results (cycle through slots) |
| **BTNR** | Right | 🔄 Reset All Votes |

### Switches

| Switch | Function |
|--------|----------|
| **SW[0] UP** | Select Candidate 1 |
| **SW[1] UP** | Select Candidate 2 |
| Both ON / Both OFF | ❌ Invalid — vote rejected |

---

## 📟 7-Segment Display Layout

```
┌─────────┬───────────┬──────────┬──────────┐
│ Digit 3 │  Digit 2  │ Digit 1  │ Digit 0  │
│ (Left)  │           │          │ (Right)  │
├─────────┼───────────┼──────────┼──────────┤
│  Party  │ Candidate │   Tens   │   Ones   │
│  1/2/3  │   1 / 2   │  (vote)  │  (vote)  │
└─────────┴───────────┴──────────┴──────────┘
```

**Example:** Party 2, Candidate 1 has 35 votes → Display shows `2 1 3 5`

> 💡 **Decimal point ON** = You are in Result View mode

---

## 💡 LED Indicators

| LED | Meaning |
|-----|---------|
| `LED[0]` | Party 1 selected |
| `LED[1]` | Party 2 selected |
| `LED[2]` | Party 3 selected |
| `LED[3]` | Candidate 1 selected |
| `LED[4]` | Candidate 2 selected |
| `LED[13]` | Result view mode active |
| `LED[14]` | ⚠️ Invalid vote warning |
| `LED[15]` | ✅ Vote accepted flash |

---

## 🚀 How to Run in Vivado

### Step 1 — Create Project
```
1. Open Vivado
2. Click "Create Project"
3. Choose RTL Project
4. Target board: Basys3 (xc7a35tcpg236-1)
```

### Step 2 — Add Files
```
1. Add Sources → Add src/digital_voting_machine.v
2. Add Constraints → Add constraints/digital_voting_machine.xdc
3. (Optional) Add sim/tb_digital_voting_machine.v for simulation
```

### Step 3 — Simulate (Optional but Recommended)
```
1. Click "Run Simulation" → "Run Behavioral Simulation"
2. Check waveforms for correct behavior
3. Look at console for $display messages
```

### Step 4 — Synthesize & Implement
```
1. Click "Run Synthesis"  → Fix any errors/warnings
2. Click "Run Implementation"
3. Check timing report — all paths should meet timing
4. Click "Generate Bitstream"
```

### Step 5 — Program Board
```
1. Connect Basys 3 via USB
2. Click "Open Hardware Manager"
3. Click "Open Target" → "Auto Connect"
4. Click "Program Device"
5. Select the .bit file → Program
```

---

## 🧪 Simulation Notes

The testbench (`tb_digital_voting_machine.v`) covers:
- Reset functionality
- Valid vote casting (P1C1, P2C2, P3C1)
- Invalid vote rejection (both switches ON, no switches)
- Party UP and DOWN cycling
- Result mode cycling through all 6 slots
- Vote count verification via `$display` messages

> ⚠️ Note: Debounce requires 2,000,000 clock cycles per press. Simulation will take time — use the Vivado simulator with the provided testbench.

---

## ⚙️ Design Details

| Parameter | Value |
|-----------|-------|
| Clock Frequency | 100 MHz |
| Debounce Time | 20 ms (2,000,000 cycles) |
| Display Refresh Rate | ~381 Hz per digit |
| Max Votes per Slot | 9,999 |
| BCD Conversion | Double-Dabble Algorithm |
| Total Vote Slots | 6 (3 parties × 2 candidates) |

---

## 📌 Pin Assignments Summary

| Signal | FPGA Pin | Description |
|--------|----------|-------------|
| `clk` | W5 | 100 MHz clock |
| `btnC` | U18 | Cast vote |
| `btnU` | T18 | Party up |
| `btnD` | U17 | Party down |
| `btnL` | W19 | View results |
| `btnR` | T17 | Reset |
| `sw[0]` | V17 | Candidate 1 |
| `sw[1]` | V16 | Candidate 2 |
| `an[3:0]` | W4,V4,U4,U2 | Display anodes |
| `seg[6:0]` | U7,V5,U5,V8,U8,W6,W7 | Segments |
| `led[15:0]` | L1..U16 | Status LEDs |

---

## 👨‍💻 Author

**Your Name**
- GitHub: [@yourusername](https://github.com/yourusername)
- Project: Digital Voting Machine — Basys 3 FPGA

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).

---

## 🙏 Acknowledgements

- Digilent Basys 3 Reference Manual
- Xilinx Vivado Documentation
- Double-Dabble BCD Algorithm
