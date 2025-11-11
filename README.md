## Overview

This repository contains a complete SystemVerilog testbench for verifying a Circular Synchronous FIFO design. The testbench demonstrates transaction-level modeling using object-oriented programming concepts including classes, virtual interfaces, constrained randomization, and mailbox communication.

## Features

### RTL Design
- 64-entry deep × 8-bit wide synchronous FIFO
- Asynchronous active-high reset
- Concurrent read/write operations support
- Status flags: `buffer_empty`, `buffer_full`
- 7-bit occupancy counter
- Overflow and underflow protection

### Testbench Components
- **Interface** (`FIFO_if`): Bundles all DUT signals with clock
- **Transaction Class**: Randomizable data structure for read/write operations
- **Generator Class**: Creates randomized transactions using constrained randomization
- **Driver Class**: Applies transactions to DUT via virtual interface with protocol-compliant timing
- **Mailbox**: Thread-safe communication channel between generator and driver
- **Concurrent Execution**: Fork-join constructs for parallel stimulus generation and driving

---

## Architecture

```
Generator → Mailbox → Driver → Virtual Interface → DUT (FIFO)
    ↓                              ↓
Transaction                   FIFO_if
(randomized)                (clk, rst, signals)
```

### Component Flow
1. **Generator** creates randomized transactions (10 transactions in current implementation)
2. **Mailbox** (`gen2drv`) transfers transactions from generator to driver
3. **Driver** retrieves transactions and applies them to DUT through virtual interface
4. **Driver** monitors DUT responses and displays results

---

## File Structure

```
├── FIFO.sv              # RTL design (64×8 synchronous FIFO)
└── testbench.sv         # Complete testbench with:
    ├── FIFO_if          # Interface definition
    ├── transaction      # Transaction class
    ├── generator        # Generator class
    ├── driver           # Driver class
    └── tb               # Top-level testbench module
```

## Design Specifications

| Parameter | Value |
|-----------|-------|
| Depth | 64 entries |
| Data Width | 8 bits |
| Pointer Width | 6 bits |
| Counter Width | 7 bits (0-64) |
| Reset | Asynchronous, active high |
| Clock | Single clock domain |

### Interface Signals
- `clk` - Clock input
- `rst` - Asynchronous reset
- `write_en` - Write enable
- `read_en` - Read enable  
- `buf_in[7:0]` - Write data
- `buf_out[7:0]` - Read data
- `count[6:0]` - Current occupancy
- `buffer_empty` - Empty flag
- `buffer_full` - Full flag

## Testbench Operation

### Initialization
1. Clock generation starts (10ns period, 5ns half-period)
2. Mailbox created for generator-driver communication
3. Driver and generator instantiated with proper handles

### Test Sequence
1. **Reset**: Driver performs reset sequence
   - Assert `rst = 1` for 2 clock cycles
   - Deassert `rst = 0`
   - Verify initial state

2. **Stimulus Generation**: Generator creates 10 randomized transactions
   - Each transaction has random `write_en`, `read_en`, and `buf_in`
   - Transactions placed in mailbox

3. **Transaction Execution**: Driver retrieves and applies transactions
   - Applies protocol-compliant signal timing
   - Monitors and displays responses

4. **Completion**: Simulation runs for 200ns then finishes

---

## Sample Output

```
[DRIVER] Reset complete
[DRIVER] Read -> buf_out=0 count=0 empty=1
[DRIVER] Write -> buf_in=e1
[DRIVER] Write -> buf_in=66
[DRIVER] Write -> buf_in=8c
[DRIVER] Read -> buf_out=e1 count=2 empty=0
[DRIVER] Write -> buf_in=6b
[DRIVER] Read -> buf_out=66 count=2 empty=0
```

### Output Analysis
- Data read in FIFO order (first-in, first-out)
- Count accurately tracks FIFO occupancy
- Empty flag correctly asserts when count = 0
- Concurrent read-write operations maintain count correctly

---

## Key SystemVerilog Concepts Demonstrated

### 1. Object-Oriented Programming
- **Classes**: `transaction`, `generator`, `driver`
- **Constructors**: `new()` functions for initialization
- **Methods**: Tasks and functions within classes
- **Handles**: Dynamic object creation and references

### 2. Virtual Interfaces
- Enables classes to access interface signals
- Bridges static (module) and dynamic (class) domains
- Allows reusable verification components

### 3. Constrained Randomization
- `rand` variables in transaction class
- `randomize()` method for automatic stimulus generation
- Enables comprehensive functional coverage

### 4. Mailbox Communication
- Thread-safe inter-process communication
- Decouples generator and driver
- `put()` and `get()` methods for data transfer

### 5. Concurrent Processes
- `fork-join_none` for parallel execution
- Generator and driver run simultaneously
- Non-blocking process initiation


## Verification Status

| Feature | Status |
|---------|--------|
| Interface-based connectivity 
| Transaction class with randomization 
| Generator with mailbox 
| Driver with virtual interface 
| Reset task 
| Concurrent read-write testing 
| Random stimulus generation 
| Response monitoring 

---

## Requirements

- **Simulator**: ModelSim/QuestaSim, VCS, or Vivado Simulator
- **Language**: SystemVerilog (IEEE 1800-2017)
- **Minimum Version**: 
  - ModelSim 10.7+
  - VCS 2020.03+
  - Vivado 2021.1+

---

## License

MIT License - See LICENSE file for details


**Last Updated**: 11th November 2025
