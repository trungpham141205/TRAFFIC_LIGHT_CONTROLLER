# Traffic Light Controller FSM

A SystemVerilog Moore-style finite-state machine that sequences red, green and yellow outputs using a shared down-counter.

## Design status

| Item | Status |
|---|---|
| Synthesizable RTL | Implemented |
| Waveform stimulus testbench | Implemented |
| Self-checking testbench | Not implemented |
| Assertions/coverage | Not implemented |

## Interface

| Port | Direction | Width | Description |
|---|---|---:|---|
| `clk` | Input | 1 | Rising-edge system clock |
| `rstn` | Input | 1 | Asynchronous active-low reset |
| `red_light` | Output | 1 | Red lamp control |
| `green_light` | Output | 1 | Green lamp control |
| `yellow_light` | Output | 1 | Yellow lamp control |

## State sequence

```text
reset -> IDLE -> RED -> GREEN -> YELLOW -> RED -> ...
```

`IDLE` and `RED` both drive the red output. The default branch also returns the controller to a safe red-light state.

### Encodings and durations

| State | Encoding | Loaded counter | Effective residence |
|---|---:|---:|---:|
| `IDLE` | `2'b00` | 9 | 10 active clock edges |
| `RED` | `2'b01` | 4 | 5 active clock edges |
| `GREEN` | `2'b10` | 4 | 5 active clock edges |
| `YELLOW` | `2'b11` | 2 | 3 active clock edges |

The residence time is `loaded value + 1` because the FSM transitions when the current counter value is zero. This detail is important when mapping clock cycles to real-world seconds.

## RTL partitioning

- State register: asynchronous reset, sequential state update.
- Next-state logic: determines the transition and next counter load.
- Output decode: Moore outputs depend only on `current_state`.
- Datapath: 4-bit down-counter with asynchronous reset.

The output decode guarantees exactly one lamp is active for every legal state.

## Repository structure

```text
.
├── traffic_light_controller.sv
└── tb_traffic_light_controller.sv
```

## Verification

The current testbench generates a 10 ns clock, performs an initial reset, observes the FSM for 400 ns, asserts reset again during operation and then runs for another 100 ns. It dumps `dump.vcd` and prints internal state/counter values through hierarchical references.

It is a waveform-oriented smoke test only: there is no reference model, automatic PASS/FAIL decision, assertion or functional coverage.

### Run with Icarus Verilog

```bash
iverilog -g2012 -o traffic_tb \
  traffic_light_controller.sv tb_traffic_light_controller.sv
vvp traffic_tb
gtkwave dump.vcd
```

### Recommended self-checking plan

| Test | Expected behavior |
|---|---|
| Reset from every state | Immediate `IDLE`, red on, counter reloaded |
| State order | `IDLE -> RED -> GREEN -> YELLOW -> RED` |
| State duration | Exact residence times from the table above |
| Output mapping | One-hot lamp outputs; red in `IDLE` and `RED` |
| Long run | Multiple complete loops without counter underflow |

For hardware use, replace the small demonstration counts with parameterized cycle counts derived from the system clock frequency.

