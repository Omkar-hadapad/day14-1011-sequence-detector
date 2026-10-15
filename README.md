# Day 14 — 1011 Sequence Detector

<p align="center">
  <b>Digital VLSI • Verilog RTL • FSM Design • Functional Verification • Cadence Genus</b>
</p>

<p align="center">
  <code>Specification → RTL → Testbench → Simulation → Synthesis → Technology Mapping → Area → Power → Timing → PPA Review</code>
</p>

<p align="center">
  <img alt="Project" src="https://img.shields.io/badge/Project-Day%2014-blue">
  <img alt="HDL" src="https://img.shields.io/badge/HDL-Verilog-8A2BE2">
  <img alt="Synthesis" src="https://img.shields.io/badge/Synthesis-Cadence%20Genus-orange">
  <img alt="Verification" src="https://img.shields.io/badge/Verification-446%20Pass%20%7C%200%20Fail-success">
</p>

---

## 1. Project Information

| Parameter | Details |
|---|---|
| **Project** | Day 14 — 1011 Sequence Detector Verification Review |
| **Author** | Omkar Kalmesh Hadapad |
| **Domain** | Digital VLSI / RTL Design / Functional Verification |
| **Design Type** | Finite-state machine (FSM) sequence detector |
| **Detected Sequence** | `1011` |
| **HDL** | Verilog HDL |
| **Simulation Tool** | Cadence Xcelium (`ncsim`) |
| **Synthesis Tool** | Cadence Genus 21.14-s082_1 |
| **Library** | `tsmc18` |
| **Top Module** | `sequence_detector_1011_top` |
| **Analysis** | Verification, hierarchy, standard-cell area, power, timing |
| **Simulation Summary** | 446 reported passes, 0 reported failures |
| **Physical-Design Status** | Post-route implementation and extracted-parasitic closure are not established by the available reports |

> **Measurement note:** The area report gives `362.578`; the supplied report context does not explicitly confirm its physical unit. It is therefore presented as *reported area units*, not assumed to be µm².

---

## 2. Project Overview

A 1011 sequence detector monitors a serial input and asserts its detection output when the bit pattern `1011` is received. The FSM stores progress through the pattern in its current state and uses the current input bit to determine the next state.

The project includes RTL and structural implementation hierarchy, a simulation transcript, and Cadence Genus synthesis reports. The synthesis results are a snapshot of the reported implementation; they must not be described as final post-layout PPA without physical-design and extracted-parasitic reports.

### Detection concept

```text
Serial input:  1 → 0 → 1 → 1
                         │
                         ▼
                  Sequence detected
```

The exact output timing and overlap behavior depend on the FSM specification and implementation. The simulation transcript reports tests for detection, non-detection, reset recovery, state transitions, and overlapping input sequences.

---

## 3. Objectives

1. Understand FSM-based serial sequence detection.
2. Verify detection of the input pattern `1011`.
3. Exercise state transitions, reset behavior, and recovery.
4. Test input sequences that should and should not trigger detection.
5. Compare RTL and structural detection outputs in simulation.
6. Review the Genus hierarchy and mapped standard cells.
7. Analyze reported area and sequential/combinational distribution.
8. Interpret internal, switching, and leakage power.
9. Read a timing path and calculate setup slack.
10. Identify the limits of simulation and synthesis-stage evidence.

---

## 4. Day 14 — 1011 Sequence Detector Verification Review

### 1. Verification summary

| Verification item | Reported result |
|---|---:|
| Final pass count | **446** |
| Final fail count | **0** |
| Testbench result | **ALL TESTS PASSED** |
| Day status in transcript | **DAY 14 VERIFICATION SUCCESSFUL** |
| Simulator termination | `$finish` at approximately 956 ns |

The supplied simulation transcript reports 446 passes and zero failures. This establishes that the checks executed by that testbench passed; it is not, by itself, a formal-equivalence proof or ASIC sign-off.

### 2. Tests covered in the log

The transcript includes checks for:

- Basic gates and a 2:1 mux.
- D flip-flop reset and capture behavior.
- Two-bit state-register behavior.
- FSM state transitions and output logic.
- Reset behavior and reset recovery.
- Detection of `1011`.
- Non-detection sequences such as `000000`, `111111`, and `1000`.
- Partial and embedded patterns such as `101` and `0001011`.
- Overlapping/repeated sequences such as `1011011`.
- RTL-versus-structural output agreement.
- Repeated overlap and transition checks.

### 3. Important verification observation

The transcript contains cycles where the structural and RTL outputs agree with one another while the printed `MODEL` value differs on some later samples. This may be related to reference-model update timing or the testbench sampling phase, but the log alone is not sufficient to determine the cause.

**Recommended check:** inspect the reference-model update order, clock-edge sampling, and when the testbench compares the model with the DUT outputs. Do not treat this observation as a confirmed RTL defect without checking the testbench timing and intended sequence-detector specification.

---

## 5. What hardware does this RTL create?

A sequence detector generally contains sequential state storage and combinational next-state/output logic.

```text
                  ┌─────────────────────┐
  serial input ──►│ Next-state / decode  │
                  │ logic               │
                  └──────────┬──────────┘
                             │ next state
                             ▼
                  ┌─────────────────────┐
        clock ───►│ State registers     │
        reset ───►│                     │
                  └──────────┬──────────┘
                             │ current state
                             └─────── feedback to logic

                  Current state + input
                            │
                            ▼
                    Detection output
```

The synthesis report lists four sequential standard-cell instances in the reported mapped-cell summary. The hierarchy and mapped netlist should be inspected together to confirm how those cells correspond to logical state bits and any implementation-specific register structures.

---

## 6. Genus Synthesis Report Analysis

### 1. Overall synthesis results

| Metric | Reported result |
|---|---:|
| Top module | `sequence_detector_1011_top` |
| Mapped standard-cell instances | **16** |
| Total reported cell area | **362.578 area units** |
| Total reported power | **23.5621 µW** |
| Timing path slack | **+7.427 ns** |
| Synthesis library | `tsmc18` |
| Synthesis tool | Cadence Genus 21.14-s082_1 |

> The area, power, and timing values above are synthesis-report results. The timing excerpt shows wireload-mode analysis; post-route timing and extracted-parasitic PPA are not established.

### 2. Standard-cell breakdown

| Standard cell | Instances | Reported area |
|---|---:|---:|
| `AND2X2` | 2 | 26.611 |
| `AND3X2` | 1 | 16.632 |
| `AOI21X1` | 1 | 13.306 |
| `DFFHQX1` | 1 | 53.222 |
| `DFFTRX1` | 1 | 56.549 |
| `DFFTRXL` | 2 | 113.098 |
| `INVX1` | 3 | 19.958 |
| `INVXL` | 1 | 6.653 |
| `NAND2BX1` | 1 | 13.306 |
| `NAND3BX1` | 1 | 16.632 |
| `NAND3X1` | 1 | 13.306 |
| `OAI21XL` | 1 | 13.306 |
| **Total** | **16** | **362.578** |

### 3. Sequential versus combinational area

| Category | Instances | Reported area | Share of total area |
|---|---:|---:|---:|
| Sequential cells | 4 | 222.869 | 61.5% |
| Inverters | 4 | 26.611 | 7.3% |
| Other combinational logic | 8 | 113.098 | 31.2% |
| Physical cells | 0 | 0.000 | 0.0% |
| **Total** | **16** | **362.578** | **100%** |

#### Area distribution graph

```text
Sequential cells          61.5%  ███████████████████████████████
Other combinational logic  31.2%  ████████████████
Inverters                  7.3%  ████
Physical cells             0.0%
```

**Interpretation:** Sequential cells account for the largest reported share of mapped area. This is a cell-area distribution, not a floorplan/core-area measurement. Cell counts and hierarchy entries should be cross-checked against the mapped netlist before assigning every mapped flop to a specific logical state bit.

---

## 7. Genus Hierarchy Report Analysis

### 1. Hierarchy tree

The hierarchy report identifies the top-level detector and RTL/structural branches as follows:

```text
sequence_detector_1011_top
├── RTL (sequence_detector_1011_rtl)
└── STRUCTURAL (sequence_detector_1011_structural)
    ├── NEXT_LOGIC
    ├── OUTPUT_LOGIC
    │   ├── AND gate instance
    │   └── AND gate instance
    └── STATE_REG
        ├── FF0
        └── FF1
```

### 2. What each module does

| Hierarchy block | Role indicated by its name/report |
|---|---|
| `sequence_detector_1011_top` | Top-level integration of the sequence detector |
| `sequence_detector_1011_rtl` | RTL-style implementation branch |
| `sequence_detector_1011_structural` | Structural implementation branch |
| `NEXT_LOGIC` | Combinational next-state logic |
| `OUTPUT_LOGIC` | Detection/output logic; the report lists two AND-gate instances below this block |
| `STATE_REG` | State-storage hierarchy containing `FF0` and `FF1` |

### Hierarchy area summary

| Hierarchy block | Cell count | Reported area |
|---|---:|---:|
| `sequence_detector_1011_top` | 16 | 362.578 |
| `sequence_detector_1011_rtl` | 7 | 176.299 |
| `sequence_detector_1011_structural` | 9 | 186.278 |

**Interpretation limit:** A hierarchy listing alone does not prove that both branches are independently active in the final output path or that the branch areas represent a fair comparison. Inspect the top-level RTL and mapped netlist to confirm connectivity, optimization, and whether each branch is used. Do not add parent and child area values together as though they were independent blocks.

---

## 8. Genus Power Report Analysis

### 1. Overall power summary

| Metric | Reported power |
|---|---:|
| **Total power** | **2.35621e-05 W = 23.5621 µW** |
| Register total | 20.8540 µW |
| Logic total | Approximately 0.004979 µW (4.97932 nW) |
| Clock switching | 2.70313 µW |
| Subtotal leakage | 0.0113188 µW (11.3188 nW) |

### 2. Power breakdown

| Category | Reported power | Share of total (approx.) |
|---|---:|---:|
| Register | 20.8540 µW | 88.51% |
| Clock switching | 2.70313 µW | 11.47% |
| Logic leakage/total logic shown | 0.00497932 µW | 0.02% |
| **Total** | **23.5621 µW** | **100%** |

The report's subtotal components are approximately:

| Power component | Reported value |
|---|---:|
| Leakage | `1.13188e-08 W` |
| Internal | `2.08476e-05 W` |
| Switching | `2.70313e-06 W` |
| **Total** | **2.35621e-05 W** |

### Power distribution by category

Percentages from the reported power summary:

```text
Register power       88.51%  ████████████████████████████████████████████
Clock switching      11.47%  ██████
Logic                ~0.02%  ▏
```

### Power interpretation and limitations

- The reported total is **23.5621 µW**.
- Register power is the dominant reported category.
- The logic category has almost no reported internal/switching contribution in this report excerpt.
- Zero or near-zero combinational switching should not automatically be interpreted as real-world zero logic activity. Confirm the clock setup, input stimulus, and activity annotation (for example, VCD/SAIF or the applicable Genus activity setup).
- Treat this as a synthesis-stage estimate for the reported analysis conditions, not confirmed post-route or silicon power.

---

## 9. Genus Timing Report Analysis

### 1. Key timing results

| Timing item | Reported value |
|---|---:|
| Path status | **MET** |
| Setup slack | **+7427 ps = +7.427 ns** |
| Launch clock edge | 0 ps |
| Capture clock edge | 10,000 ps (10 ns) |
| Input delay | 1,000 ps (1 ns) |
| Setup time | 398 ps |
| Clock uncertainty | 1,000 ps |
| Data arrival time | 1,175 ps |
| Required time | 8,602 ps |
| Data path delay | Approximately 175 ps |

### 2. Understand the timing path

```text
din
 │
 ▼
NAND3X1   (reported cell delay: 78 ps)
 │
 ▼
OAI21XL   (reported cell delay: 96 ps)
 │
 ▼
STRUCTURAL/STATE_REG/FF1/Q_reg/D
```

The reported path starts at input `din` and ends at the D pin of a state-register element. The two listed combinational cell delays total approximately 174 ps, rounded to about 175 ps in the report.

### 3. How Genus calculates the slack

The report gives a required time of approximately 8602 ps and an arrival time of 1175 ps.

\[
\text{Slack} = \text{Required Time} - \text{Arrival Time}
\]

\[
\text{Slack} = 8602\text{ ps} - 1175\text{ ps} = 7427\text{ ps}
\]

Therefore, the displayed path has **+7.427 ns slack** and is marked **MET**.

### Timing interpretation and limitations

- Positive slack means this reported path meets its timing requirement under the shown constraints.
- One MET path does not prove that all setup and hold paths meet timing.
- The report context uses wireload-mode analysis; it does not establish routed interconnect delay or extracted-parasitic timing.
- Review the full timing summary, worst negative slack (WNS), total negative slack (TNS), setup and hold paths, and the SDC constraints.
- Confirm that the 10 ns clock, input delay, uncertainty, and any path exceptions accurately represent the intended design environment.

---

## 10. PPA Summary

| Metric | Result | Evidence / qualification |
|---|---:|---|
| Mapped standard-cell count | 16 | Genus cell summary |
| Total reported area | 362.578 area units | Physical area unit not confirmed in the excerpt |
| Total reported power | 23.5621 µW | Synthesis-stage power estimate |
| Reported timing slack | +7.427 ns | One input-to-register setup path |
| Path status | MET | Applies to the displayed path only |
| Simulation | 446 pass / 0 fail | Supplied Xcelium transcript |
| Post-route PPA | Not established | No extracted-parasitic post-route evidence in the reviewed reports |

---

## 11. Important observations

1. The supplied simulation log reports 446 passes and zero failures.
2. The mapped-cell report lists 16 standard-cell instances with a reported area of 362.578.
3. Sequential cells account for approximately 61.5% of the reported mapped area.
4. Register power is the largest reported power category at approximately 88.51%.
5. The displayed input-to-register timing path is marked MET with +7.427 ns slack.
6. The hierarchy report lists both RTL and structural branches; top-level connectivity must be checked before treating them as independent implementations.
7. The model-versus-DUT output difference visible in some log samples should be investigated by checking testbench sampling and reference-model timing.
8. The available evidence does not establish post-route timing, extracted-parasitic power, or final physical-design closure.

---

## 12. Tests covered in the log

| Test area | Evidence visible in transcript |
|---|---|
| Basic combinational blocks | Basic gates and 2:1 mux checks |
| Sequential behavior | DFF reset/capture and state-register checks |
| FSM behavior | State-transition and output-logic checks |
| Target sequence | `1011` detection |
| Negative sequences | `000000`, `111111`, `1000` |
| Partial/embedded patterns | `101`, `0001011` |
| Overlap/repeated pattern | `1011011` and repeated-overlap checks |
| Reset | Reset behavior and recovery checks |
| Implementation comparison | Structural-versus-RTL checks |
| Final transcript summary | 446 pass, 0 fail, all tests passed |

---

## 13. Recommended Repository Structure

```text
 day14-1011-sequence-detector/
 ├── README.md
 ├── rtl/
 │   ├── sequence_detector_1011_top.v
 │   ├── sequence_detector_1011_rtl.v
 │   └── sequence_detector_1011_structural.v
 ├── tb/
 │   └── tb_sequence_detector_1011.v
 ├── sim/
 │   ├── simulation.log
 │   └── waveform/
 ├── genus/
 │   ├── constraints_top.sdc
 │   ├── reports/
 │   │   ├── hierarchy.rpt
 │   │   ├── area.rpt
 │   │   ├── power.rpt
 │   │   └── timing.rpt
 │   ├── mapped_netlist.v
 │   └── synthesis.log
 ├── images/
 │   ├── verification_summary.png
 │   ├── hierarchy.png
 │   ├── area_distribution.png
 │   ├── power_distribution.png
 │   └── timing_path.png
 └── docs/
     └── Day14_Sequence_Detector_Report.pdf
```

> This is a suggested repository layout. Adjust filenames to match the actual files in the project. The graph-style bars in this README are text-based summaries; replace or supplement them with exported report screenshots/plots when those image files are available.

---

## 14. Industry Relevance

Sequence detectors are used in protocol recognition, serial data processing, control logic, and finite-state-machine-based digital systems. This project demonstrates the relationship between a behavioral specification, state transitions, synthesizable RTL, functional verification, and standard-cell synthesis analysis.

The reviewed reports also provide practice in interpreting mapped area, power categories, timing slack, and the limitations of synthesis-stage metrics.

---

## 15. Interview Questions

1. What is a sequence detector, and how does an FSM implement one?
2. How does the state represent progress through the sequence `1011`?
3. What is the difference between Moore and Mealy sequence detectors?
4. What is overlapping sequence detection?
5. Why is a self-checking testbench useful?
6. Why can the reference model and DUT appear misaligned if sampled at different simulation phases?
7. What does technology mapping do?
8. Why is sequential cell area a significant portion of this report?
9. What is the difference between internal, switching, and leakage power?
10. What does positive timing slack mean?
11. Why does one MET path not establish full timing closure?
12. Why should synthesis-stage PPA not be described as final post-layout PPA?

---

## 16. Project Status

| Stage | Status |
|---|---|
| Simulation transcript reviewed | Complete for the supplied log |
| Reported test checks | 446 pass / 0 fail |
| Hierarchy report reviewed | Complete for the available report excerpt |
| Standard-cell area reviewed | Complete for the available report excerpt |
| Power report reviewed | Complete for the available report excerpt; activity assumptions should be checked |
| One timing path reviewed | Complete for the available report excerpt |
| Reference-model timing observation | Requires testbench review |
| Full timing closure | Not established |
| Post-route PPA closure | Not established |

---

## 17. Final Genus Results

| Parameter | Reported value |
|---|---:|
| Top module | `sequence_detector_1011_top` |
| Standard-cell count | 16 |
| Total reported area | 362.578 area units |
| Total reported power | 23.5621 µW |
| Displayed path slack | +7.427 ns |
| Displayed path status | MET |
| Simulation summary | 446 pass / 0 fail |
| Post-route status | Not established |

**Conclusion:** The available evidence shows a successful reported simulation run and provides a synthesis-stage view of the sequence detector's hierarchy, mapped cell area, estimated power, and one timing path. The next steps are to inspect the reference-model sampling behavior, confirm top-level RTL/netlist connectivity, validate switching activity, and review full setup/hold timing and physical-design reports before claiming post-layout PPA closure.


---

## 18. Next Project — Day 15: Traffic Light Controller

The next project builds on FSM design by creating a synchronous traffic-light controller for North–South and East–West traffic.

**Planned focus:**

- Define the traffic-light states and state-transition diagram.
- Implement the controller in synthesizable Verilog.
- Verify reset behavior and legal state transitions.
- Ensure both directions never show green at the same time.
- Run simulation and review the Genus synthesis reports.

**Key learning goal:** translate a practical control specification into an FSM, RTL, and a testbench that verifies safe operation.

**Status:** Planned — not yet completed or verified.

---

## 19. Author

**Omkar Kalmesh Hadapad**  
Electronics and Communication Engineering  
Digital VLSI • Verilog RTL • Cadence Genus

---

**Day 14 Complete — Next: Day 15 · Traffic Light Controller**

---

<p align="center">
  <b>Day 14 Review — 1011 Sequence Detector · Functional Verification and Genus Report Analysis</b>
</p>
