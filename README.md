# Behavioral Modeling of a 16 × 8 Synchronous RAM (Verilog)

---

## 1. What This Design Is

This project implements a **16 × 8 synchronous Random Access Memory (RAM)** using **behavioral modeling in Verilog HDL**.

Key characteristics:

* **Depth**: 16 memory locations
* **Width**: 8-bit data per location
* **Single clock domain**
* **Synchronous write operation**
* **Synchronous read operation**
* **Synchronous reset**

This design models the **functional behavior** of a real FPGA block RAM rather than an idealized or purely combinational memory.

---

## 2. Why This RAM Is Important

Synchronous RAMs are **core building blocks** in digital and FPGA-based systems.

They are commonly used in:

* Register files
* Scratchpad memories
* FIFO buffers (internally)
* Simplified cache structures
* Embedded processors (e.g., MicroBlaze, RISC-V)
* FPGA-based accelerators (DSP, machine learning, signal processing)

In modern digital hardware, **most on-chip memories are synchronous**, making this design representative of real hardware.

---

<img width="889" height="762" alt="image" src="https://github.com/user-attachments/assets/8b9dfcec-dbe2-4516-9cc4-28249420cc26" />

---

## 3. Behavioral Modeling Explained

This RAM is written using **behavioral Verilog**, meaning:

* The design describes *how the memory behaves*, not its physical structure.
* The memory array is modeled using a `reg` array.
* Timing and functionality are defined relative to clock edges.

Behavioral modeling is commonly used for:

* Functional verification
* Early design validation
* Teaching and architectural exploration

---

## 4. RAM Architecture Overview

### Ports

| Signal | Width | Purpose           |
| ------ | ----- | ----------------- |
| `clk`  | 1     | System clock      |
| `rst`  | 1     | Synchronous reset |
| `we`   | 1     | Write enable      |
| `re`   | 1     | Read enable       |
| `addr` | 4     | Address (0–15)    |
| `din`  | 8     | Data input        |
| `dout` | 8     | Data output       |

### Memory Array

```verilog
reg [7:0] mem [0:15];
```

This represents:

* 16 memory entries
* Each entry storing 8 bits of data

---

## 5. Why Read and Write Are Synchronous

Both read and write operations occur inside:

```verilog
always @(posedge clk)
```

### Reasoning

* Real hardware RAM updates only on clock edges
* FPGA block RAMs require synchronous read
* This introduces a **one-clock-cycle latency**

As a result:

* Data written in clock cycle **N**
* Becomes visible when read in cycle **N + 1**

This latency is **expected and correct**, not a flaw.

---

## 6. Why Reset Is Synchronous

Reset behavior:

```verilog
if (rst) begin
    mem[i] <= 0;
    dout   <= 0;
end
```

### Why synchronous reset?

* Aligns with FPGA design best practices
* Avoids asynchronous timing hazards
* Easier timing closure
* Predictable simulation and synthesis behavior

---

## 7. Why the Testbench Uses `negedge clk`

### Key Observation

* RAM samples signals on **posedge clk**
* Testbench drives signals on **negedge clk**

Example:

```verilog
@(negedge clk)
we   = 1'b1;
din  = data;
addr = address;
```

### Why this matters

If inputs were changed on the **same edge** as sampling:

* Race conditions could occur
* Simulation results could be ambiguous or incorrect

By driving inputs on `negedge`:

* Signals stabilize **before the next posedge**
* The RAM samples clean, settled values

This mirrors real hardware timing:

> Control and data signals must settle before the active clock edge.

---

## 8. Why `dout` Updates One Cycle Later

From the simulation:

```
tme=80000 | clk=0 addr=1100
tme=90000 | clk=1 dout=00011110
```

Explanation:

1. Address and `re` are asserted on `negedge`
2. RAM samples at the next `posedge`
3. `dout` updates on that `posedge`

This confirms:

* The RAM is synchronous
* The design accurately models real hardware behavior

---

## 9. Why `dout` Holds Its Value When `re = 0`

RAM logic:

```verilog
if (re)
    dout <= mem[addr];
```

When `re = 0`:

* No assignment occurs
* `dout` retains its previous value

This is intentional:

* Prevents glitches
* Matches block RAM behavior
* Ensures predictable downstream logic

---

## 10. Blocking vs Non-Blocking Assignments (Important Concept)

### Blocking Assignment (`=`)

* Executes immediately
* Used in **combinational logic**
* Order of execution matters

Example:

```verilog
a = b;
c = a;
```

### Non-Blocking Assignment (`<=`)

* Scheduled to update at the end of the time step
* Used in **sequential (clocked) logic**
* Models flip-flop behavior correctly

Example:

```verilog
a <= b;
c <= a;
```

### Why This RAM Uses Non-Blocking Assignments

* Memory and registers update on clock edges
* Multiple signals must update **simultaneously**
* Prevents race conditions

Using blocking assignments inside `always @(posedge clk)` would result in **incorrect hardware modeling**.

---

## 11. Final Notes for Future Reference

* One-cycle read latency is **correct**
* Stable `dout` when `re=0` is **intentional**
* `negedge` stimulus in testbench avoids races
* Behavioral RAM ≠ combinational memory

If something appears “slow” in simulation, it usually means the RAM is behaving **correctly**.

---

