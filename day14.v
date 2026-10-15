`timescale 1ns/1ps

//==============================================================
// DAY 14
// 1011 SEQUENCE DETECTOR
// Digital VLSI / Verilog RTL / FSM
//
// Pattern : 1011
// FSM Type: Mealy
// Detection: Overlapping
//
// Hierarchy:
// Gates
//   ↓
// D Flip-Flop
//   ↓
// State Register
//   ↓
// Next-State Logic
//   ↓
// Output Logic
//   ↓
// 1011 Sequence Detector
//   ↓
// RTL Sequence Detector
//   ↓
// Top Module
//==============================================================


//==============================================================
// LEVEL 1 : BASIC GATES
//==============================================================

module not_gate(
    input  A,
    output Y
);
    assign Y = ~A;
endmodule


module and_gate(
    input A,
    input B,
    output Y
);
    assign Y = A & B;
endmodule


module or_gate(
    input A,
    input B,
    output Y
);
    assign Y = A | B;
endmodule


module xor_gate(
    input A,
    input B,
    output Y
);
    assign Y = A ^ B;
endmodule


//==============================================================
// LEVEL 2 : 2-INPUT MUX
//==============================================================

module mux_2to1(
    input I0,
    input I1,
    input S,
    output Y
);

    wire S_not;
    wire W0;
    wire W1;

    not_gate U1(
        .A(S),
        .Y(S_not)
    );

    and_gate U2(
        .A(I0),
        .B(S_not),
        .Y(W0)
    );

    and_gate U3(
        .A(I1),
        .B(S),
        .Y(W1)
    );

    or_gate U4(
        .A(W0),
        .B(W1),
        .Y(Y)
    );

endmodule


//==============================================================
// LEVEL 3 : D FLIP-FLOP WITH SYNCHRONOUS RESET
//==============================================================

module dff_sync_reset(
    input clk,
    input reset,
    input D,
    output reg Q
);

    always @(posedge clk)
    begin
        if(reset)
            Q <= 1'b0;
        else
            Q <= D;
    end

endmodule


//==============================================================
// LEVEL 4 : 2-BIT STATE REGISTER
//==============================================================

module state_register_2bit(
    input clk,
    input reset,
    input [1:0] next_state,
    output [1:0] state
);

    dff_sync_reset FF0(
        .clk(clk),
        .reset(reset),
        .D(next_state[0]),
        .Q(state[0])
    );

    dff_sync_reset FF1(
        .clk(clk),
        .reset(reset),
        .D(next_state[1]),
        .Q(state[1])
    );

endmodule


//==============================================================
// LEVEL 5 : NEXT-STATE LOGIC
//
// State encoding:
//
// S0 = 00
// S1 = 01
// S2 = 10
// S3 = 11
//
// Transition:
//
// S0 + 0 -> S0
// S0 + 1 -> S1
//
// S1 + 0 -> S2
// S1 + 1 -> S1
//
// S2 + 0 -> S0
// S2 + 1 -> S3
//
// S3 + 0 -> S2
// S3 + 1 -> S1
//==============================================================

module sequence_1011_next_state(
    input [1:0] state,
    input din,
    output reg [1:0] next_state
);

    localparam S0 = 2'b00;
    localparam S1 = 2'b01;
    localparam S2 = 2'b10;
    localparam S3 = 2'b11;

    always @(*)
    begin

        // Default state
        next_state = S0;

        case(state)

            S0:
            begin
                if(din)
                    next_state = S1;
                else
                    next_state = S0;
            end

            S1:
            begin
                if(din)
                    next_state = S1;
                else
                    next_state = S2;
            end

            S2:
            begin
                if(din)
                    next_state = S3;
                else
                    next_state = S0;
            end

            S3:
            begin
                if(din)
                    next_state = S1;
                else
                    next_state = S2;
            end

            default:
                next_state = S0;

        endcase

    end

endmodule


//==============================================================
// LEVEL 6 : MEALY OUTPUT LOGIC
//
// Detection occurs when:
//
// Current state = S3
// Input          = 1
//
// S3 represents "101"
// Input 1 gives "1011"
//==============================================================

module sequence_1011_output(
    input [1:0] state,
    input din,
    output detected
);

    wire state_bit0;
    wire state_bit1;
    wire state_s3;
    wire detect_temp;

    assign state_bit0 = state[0];
    assign state_bit1 = state[1];

    // S3 = 11
    and_gate U1(
        .A(state_bit0),
        .B(state_bit1),
        .Y(state_s3)
    );

    // Detection = S3 AND din
    and_gate U2(
        .A(state_s3),
        .B(din),
        .Y(detect_temp)
    );

    assign detected = detect_temp;

endmodule


//==============================================================
// LEVEL 7 : STRUCTURAL 1011 SEQUENCE DETECTOR
//==============================================================

module sequence_detector_1011_structural(
    input clk,
    input reset,
    input din,
    output detected,
    output [1:0] state,
    output [1:0] next_state
);

    // State register
    state_register_2bit STATE_REG(
        .clk(clk),
        .reset(reset),
        .next_state(next_state),
        .state(state)
    );

    // Next-state logic
    sequence_1011_next_state NEXT_LOGIC(
        .state(state),
        .din(din),
        .next_state(next_state)
    );

    // Output logic
    sequence_1011_output OUTPUT_LOGIC(
        .state(state),
        .din(din),
        .detected(detected)
    );

endmodule


//==============================================================
// LEVEL 8 : BEHAVIORAL RTL 1011 SEQUENCE DETECTOR
//==============================================================

module sequence_detector_1011_rtl(
    input clk,
    input reset,
    input din,
    output reg detected
);

    localparam S0 = 2'b00;
    localparam S1 = 2'b01;
    localparam S2 = 2'b10;
    localparam S3 = 2'b11;

    reg [1:0] state;
    reg [1:0] next_state;

    //==========================================================
    // STATE REGISTER
    //==========================================================

    always @(posedge clk)
    begin
        if(reset)
            state <= S0;
        else
            state <= next_state;
    end


    //==========================================================
    // NEXT-STATE LOGIC
    //==========================================================

    always @(*)
    begin

        next_state = S0;

        case(state)

            S0:
            begin
                if(din)
                    next_state = S1;
                else
                    next_state = S0;
            end

            S1:
            begin
                if(din)
                    next_state = S1;
                else
                    next_state = S2;
            end

            S2:
            begin
                if(din)
                    next_state = S3;
                else
                    next_state = S0;
            end

            S3:
            begin
                if(din)
                    next_state = S1;
                else
                    next_state = S2;
            end

            default:
                next_state = S0;

        endcase

    end


    //==========================================================
    // MEALY OUTPUT
    //==========================================================

    always @(*)
    begin

        if((state == S3) && (din == 1'b1))
            detected = 1'b1;
        else
            detected = 1'b0;

    end

endmodule


//==============================================================
// LEVEL 9 : TOP MODULE
//
// Structural and RTL versions are instantiated together.
// This allows direct comparison during simulation.
//==============================================================

module sequence_detector_1011_top(
    input clk,
    input reset,
    input din,

    output detected_structural,
    output detected_rtl,

    output [1:0] state_structural,
    output [1:0] next_state_structural
);

    sequence_detector_1011_structural STRUCTURAL(
        .clk(clk),
        .reset(reset),
        .din(din),
        .detected(detected_structural),
        .state(state_structural),
        .next_state(next_state_structural)
    );


    sequence_detector_1011_rtl RTL(
        .clk(clk),
        .reset(reset),
        .din(din),
        .detected(detected_rtl)
    );

endmodule