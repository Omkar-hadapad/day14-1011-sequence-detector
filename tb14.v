`timescale 1ns/1ps

//==============================================================
// DAY 14 - 1011 SEQUENCE DETECTOR
// SELF-CHECKING VERIFICATION TESTBENCH
//
// DUTs tested:
// 1. Basic gates
// 2. 2:1 MUX
// 3. D Flip-Flop
// 4. 2-bit State Register
// 5. Next-State Logic
// 6. Output Logic
// 7. Structural 1011 Detector
// 8. RTL 1011 Detector
//
// Sequence : 1011
// FSM      : S0 -> S1 -> S2 -> S3
// Overlap  : Supported
//
// Verification:
// - Directed testing
// - All FSM transitions
// - Reset verification
// - Sequence detection
// - Overlap detection
// - Structural vs RTL comparison
// - Reference-model comparison
// - Automatic PASS/FAIL count
//==============================================================

module tb_sequence_detector_1011;

    //==========================================================
    // TEST CONTROL
    //==========================================================

    integer pass_count;
    integer fail_count;

    reg clk;
    reg reset;

    //==========================================================
    // CLOCK
    //==========================================================

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    //==========================================================
    // BASIC GATES
    //==========================================================

    reg A;
    reg B;

    wire not_y;
    wire and_y;
    wire or_y;
    wire xor_y;

    not_gate U_NOT (
        .A(A),
        .Y(not_y)
    );

    and_gate U_AND (
        .A(A),
        .B(B),
        .Y(and_y)
    );

    or_gate U_OR (
        .A(A),
        .B(B),
        .Y(or_y)
    );

    xor_gate U_XOR (
        .A(A),
        .B(B),
        .Y(xor_y)
    );

    //==========================================================
    // 2:1 MUX
    //==========================================================

    reg mux_I0;
    reg mux_I1;
    reg mux_S;

    wire mux_Y;

    mux_2to1 MUX (
        .I0(mux_I0),
        .I1(mux_I1),
        .S(mux_S),
        .Y(mux_Y)
    );

    //==========================================================
    // D FLIP-FLOP
    //==========================================================

    reg dff_D;
    wire dff_Q;

    dff_sync_reset DFF (
        .clk(clk),
        .reset(reset),
        .D(dff_D),
        .Q(dff_Q)
    );

    //==========================================================
    // 2-BIT STATE REGISTER
    //==========================================================

    reg [1:0] test_next_state_reg;
    wire [1:0] test_state_reg;

    state_register_2bit STATE_REG (
        .clk(clk),
        .reset(reset),
        .next_state(test_next_state_reg),
        .state(test_state_reg)
    );

    //==========================================================
    // NEXT-STATE LOGIC
    //==========================================================

    reg [1:0] test_state;
    reg test_din;

    wire [1:0] test_next_state;

    sequence_1011_next_state NEXT (
        .state(test_state),
        .din(test_din),
        .next_state(test_next_state)
    );

    //==========================================================
    // OUTPUT LOGIC
    //==========================================================

    reg [1:0] output_state;
    reg output_din;

    wire output_detected;

    sequence_1011_output OUTPUT (
        .state(output_state),
        .din(output_din),
        .detected(output_detected)
    );

    //==========================================================
    // STRUCTURAL DUT
    //==========================================================

    wire s_detected;
    wire [1:0] s_state;
    wire [1:0] s_next_state;

    sequence_detector_1011_structural STRUCT_DUT (
        .clk(clk),
        .reset(reset),
        .din(test_din),
        .detected(s_detected),
        .state(s_state),
        .next_state(s_next_state)
    );

    //==========================================================
    // RTL DUT
    //==========================================================

    wire r_detected;

    sequence_detector_1011_rtl RTL_DUT (
        .clk(clk),
        .reset(reset),
        .din(test_din),
        .detected(r_detected)
    );

    //==========================================================
    // FSM STATES
    //==========================================================

    localparam S0 = 2'b00;
    localparam S1 = 2'b01;
    localparam S2 = 2'b10;
    localparam S3 = 2'b11;

    //==========================================================
    // REFERENCE MODEL
    //==========================================================

    reg [1:0] model_state;
    reg [1:0] expected_next;
    reg [1:0] expected_next_after_clock;

    reg model_detected;
    reg expected_detect;

    //==========================================================
    // VCD DUMP
    //==========================================================

    initial begin
        $dumpfile("day14_1011.vcd");
        $dumpvars(0,tb_sequence_detector_1011);
    end

    //==========================================================
    // 1-BIT CHECK
    //==========================================================

    task check_1bit;

        input actual;
        input expected;
        input [200:0] message;

        begin

            if(actual === expected) begin

                pass_count = pass_count + 1;

                $display(
                    "PASS : %s | Expected=%b Actual=%b",
                    message,
                    expected,
                    actual
                );

            end
            else begin

                fail_count = fail_count + 1;

                $display(
                    "FAIL : %s | Expected=%b Actual=%b",
                    message,
                    expected,
                    actual
                );

            end

        end

    endtask

    //==========================================================
    // 2-BIT CHECK
    //==========================================================

    task check_2bit;

        input [1:0] actual;
        input [1:0] expected;
        input [200:0] message;

        begin

            if(actual === expected) begin

                pass_count = pass_count + 1;

                $display(
                    "PASS : %s | Expected=%b Actual=%b",
                    message,
                    expected,
                    actual
                );

            end
            else begin

                fail_count = fail_count + 1;

                $display(
                    "FAIL : %s | Expected=%b Actual=%b",
                    message,
                    expected,
                    actual
                );

            end

        end

    endtask

    //==========================================================
    // REFERENCE NEXT-STATE FUNCTION
    //==========================================================

    function [1:0] reference_next;

        input [1:0] state;
        input din;

        begin

            case(state)

                S0:
                    if(din)
                        reference_next = S1;
                    else
                        reference_next = S0;

                S1:
                    if(din)
                        reference_next = S1;
                    else
                        reference_next = S2;

                S2:
                    if(din)
                        reference_next = S3;
                    else
                        reference_next = S0;

                S3:
                    if(din)
                        reference_next = S1;
                    else
                        reference_next = S2;

                default:
                    reference_next = S0;

            endcase

        end

    endfunction

    //==========================================================
    // REFERENCE OUTPUT FUNCTION
    //==========================================================

    function reference_output;

        input [1:0] state;
        input din;

        begin

            if((state == S3) && (din == 1'b1))
                reference_output = 1'b1;
            else
                reference_output = 1'b0;

        end

    endfunction

    //==========================================================
    // APPLY ONE INPUT BIT
    //
    // IMPORTANT:
    //
    // Current DUT output is:
    //
    // detected = current_state & din
    //           = S3 & din
    //
    // Therefore, after the clock the DUT state becomes
    // expected_next.
    //
    // The post-clock combinational output is therefore
    // evaluated using expected_next and the same din.
    //==========================================================

    task apply_bit;

        input test_bit;

        begin

            // Drive input
            test_din = test_bit;

            //==================================================
            // Calculate state transition from OLD state
            //==================================================

            expected_next =
                reference_next(model_state,test_bit);

            //==================================================
            // Advance clock
            //==================================================

            @(posedge clk);

            #1;

            //==================================================
            // Check current state
            //==================================================

            check_2bit(
                s_state,
                expected_next,
                "Structural current state"
            );

            //==================================================
            // Calculate NEXT state from NEW current state
            //==================================================

            expected_next_after_clock =
                reference_next(expected_next,test_bit);

            //==================================================
            // Check structural next-state logic
            //==================================================

            check_2bit(
                s_next_state,
                expected_next_after_clock,
                "Structural next-state"
            );

            //==================================================
            // IMPORTANT:
            // Output is evaluated using NEW state after clock
            //==================================================

            expected_detect =
                reference_output(expected_next,test_bit);

            model_detected = expected_detect;

            //==================================================
            // Check structural detector
            //==================================================

            check_1bit(
                s_detected,
                expected_detect,
                "Structural detection"
            );

            //==================================================
            // Check RTL detector
            //==================================================

            check_1bit(
                r_detected,
                expected_detect,
                "RTL detection"
            );

            //==================================================
            // Structural vs RTL
            //==================================================

            check_1bit(
                s_detected,
                r_detected,
                "Structural vs RTL"
            );

            //==================================================
            // Update reference model
            //==================================================

            model_state = expected_next;

        end

    endtask

    //==========================================================
    // RESET TASK
    //==========================================================

    task apply_reset;

        begin

            reset = 1'b1;
            test_din = 1'b0;

            @(posedge clk);

            #1;

            //==================================================
            // Structural state must be S0
            //==================================================

            check_2bit(
                s_state,
                S0,
                "Reset -> Structural S0"
            );

            //==================================================
            // Detection must be zero
            //==================================================

            check_1bit(
                s_detected,
                1'b0,
                "Reset -> Structural detection"
            );

            check_1bit(
                r_detected,
                1'b0,
                "Reset -> RTL detection"
            );

            //==================================================
            // Update reference model
            //==================================================

            model_state = S0;
            model_detected = 1'b0;

            reset = 1'b0;

        end

    endtask

    //==========================================================
    // MAIN TEST SEQUENCE
    //==========================================================

    initial begin

        //======================================================
        // INITIALIZATION
        //======================================================

        pass_count = 0;
        fail_count = 0;

        reset = 1'b0;

        A = 1'b0;
        B = 1'b0;

        mux_I0 = 1'b0;
        mux_I1 = 1'b0;
        mux_S  = 1'b0;

        dff_D = 1'b0;

        test_next_state_reg = S0;

        test_state = S0;
        test_din   = 1'b0;

        output_state = S0;
        output_din   = 1'b0;

        model_state = S0;
        model_detected = 1'b0;

        #2;

        //======================================================
        // TEST 1 : BASIC GATES
        //======================================================

        $display("\n========================================");
        $display("TEST 1 : BASIC GATES");
        $display("========================================");

        A = 0;
        B = 0;
        #1;

        check_1bit(not_y,1,"NOT 00");
        check_1bit(and_y,0,"AND 00");
        check_1bit(or_y,0,"OR 00");
        check_1bit(xor_y,0,"XOR 00");

        A = 0;
        B = 1;
        #1;

        check_1bit(not_y,1,"NOT 01");
        check_1bit(and_y,0,"AND 01");
        check_1bit(or_y,1,"OR 01");
        check_1bit(xor_y,1,"XOR 01");

        A = 1;
        B = 0;
        #1;

        check_1bit(not_y,0,"NOT 10");
        check_1bit(and_y,0,"AND 10");
        check_1bit(or_y,1,"OR 10");
        check_1bit(xor_y,1,"XOR 10");

        A = 1;
        B = 1;
        #1;

        check_1bit(not_y,0,"NOT 11");
        check_1bit(and_y,1,"AND 11");
        check_1bit(or_y,1,"OR 11");
        check_1bit(xor_y,0,"XOR 11");

        //======================================================
        // TEST 2 : 2:1 MUX
        //======================================================

        $display("\n========================================");
        $display("TEST 2 : 2:1 MUX");
        $display("========================================");

        mux_I0 = 0;
        mux_I1 = 1;

        mux_S = 0;
        #1;

        check_1bit(
            mux_Y,
            0,
            "MUX select I0"
        );

        mux_S = 1;
        #1;

        check_1bit(
            mux_Y,
            1,
            "MUX select I1"
        );

        mux_I0 = 1;
        mux_I1 = 0;

        mux_S = 0;
        #1;

        check_1bit(
            mux_Y,
            1,
            "MUX select I0 = 1"
        );

        mux_S = 1;
        #1;

        check_1bit(
            mux_Y,
            0,
            "MUX select I1 = 0"
        );

        //======================================================
        // TEST 3 : DFF
        //======================================================

        $display("\n========================================");
        $display("TEST 3 : D FLIP-FLOP");
        $display("========================================");

        reset = 1'b1;
        dff_D = 1'b1;

        @(posedge clk);
        #1;

        check_1bit(
            dff_Q,
            1'b0,
            "DFF reset"
        );

        reset = 1'b0;
        dff_D = 1'b1;

        @(posedge clk);
        #1;

        check_1bit(
            dff_Q,
            1'b1,
            "DFF capture 1"
        );

        dff_D = 1'b0;

        @(posedge clk);
        #1;

        check_1bit(
            dff_Q,
            1'b0,
            "DFF capture 0"
        );

        //======================================================
        // TEST 4 : STATE REGISTER
        //======================================================

        $display("\n========================================");
        $display("TEST 4 : 2-BIT STATE REGISTER");
        $display("========================================");

        reset = 1'b1;

        @(posedge clk);
        #1;

        check_2bit(
            test_state_reg,
            S0,
            "State register reset"
        );

        reset = 1'b0;

        test_next_state_reg = S1;

        @(posedge clk);
        #1;

        check_2bit(
            test_state_reg,
            S1,
            "State register -> S1"
        );

        test_next_state_reg = S2;

        @(posedge clk);
        #1;

        check_2bit(
            test_state_reg,
            S2,
            "State register -> S2"
        );

        test_next_state_reg = S3;

        @(posedge clk);
        #1;

        check_2bit(
            test_state_reg,
            S3,
            "State register -> S3"
        );

        //======================================================
        // TEST 5 : NEXT-STATE LOGIC
        //======================================================

        $display("\n========================================");
        $display("TEST 5 : ALL FSM TRANSITIONS");
        $display("========================================");

        test_state = S0;
        test_din = 0;
        #1;

        check_2bit(
            test_next_state,
            S0,
            "S0 + 0 -> S0"
        );

        test_din = 1;
        #1;

        check_2bit(
            test_next_state,
            S1,
            "S0 + 1 -> S1"
        );

        test_state = S1;
        test_din = 0;
        #1;

        check_2bit(
            test_next_state,
            S2,
            "S1 + 0 -> S2"
        );

        test_din = 1;
        #1;

        check_2bit(
            test_next_state,
            S1,
            "S1 + 1 -> S1"
        );

        test_state = S2;
        test_din = 0;
        #1;

        check_2bit(
            test_next_state,
            S0,
            "S2 + 0 -> S0"
        );

        test_din = 1;
        #1;

        check_2bit(
            test_next_state,
            S3,
            "S2 + 1 -> S3"
        );

        test_state = S3;
        test_din = 0;
        #1;

        check_2bit(
            test_next_state,
            S2,
            "S3 + 0 -> S2"
        );

        test_din = 1;
        #1;

        check_2bit(
            test_next_state,
            S1,
            "S3 + 1 -> S1"
        );

        //======================================================
        // TEST 6 : OUTPUT LOGIC
        //======================================================

        $display("\n========================================");
        $display("TEST 6 : OUTPUT LOGIC");
        $display("========================================");

        output_state = S0;
        output_din = 0;
        #1;

        check_1bit(
            output_detected,
            0,
            "S0 + 0 detection"
        );

        output_din = 1;
        #1;

        check_1bit(
            output_detected,
            0,
            "S0 + 1 detection"
        );

        output_state = S1;
        output_din = 0;
        #1;

        check_1bit(
            output_detected,
            0,
            "S1 + 0 detection"
        );

        output_din = 1;
        #1;

        check_1bit(
            output_detected,
            0,
            "S1 + 1 detection"
        );

        output_state = S2;
        output_din = 0;
        #1;

        check_1bit(
            output_detected,
            0,
            "S2 + 0 detection"
        );

        output_din = 1;
        #1;

        check_1bit(
            output_detected,
            0,
            "S2 + 1 detection"
        );

        output_state = S3;
        output_din = 0;
        #1;

        check_1bit(
            output_detected,
            0,
            "S3 + 0 detection"
        );

        output_din = 1;
        #1;

        check_1bit(
            output_detected,
            1,
            "S3 + 1 detection"
        );

        //======================================================
        // TEST 7 : RESET
        //======================================================

        $display("\n========================================");
        $display("TEST 7 : RESET");
        $display("========================================");

        apply_reset;

        //======================================================
        // TEST 8 : DETECT 1011
        //======================================================

        $display("\n========================================");
        $display("TEST 8 : DETECT 1011");
        $display("========================================");

        apply_bit(1);
        apply_bit(0);
        apply_bit(1);
        apply_bit(1);

        //======================================================
        // TEST 9 : NO DETECTION
        //======================================================

        $display("\n========================================");
        $display("TEST 9 : 000000");
        $display("========================================");

        apply_reset;

        apply_bit(0);
        apply_bit(0);
        apply_bit(0);
        apply_bit(0);
        apply_bit(0);
        apply_bit(0);

        //======================================================
        // TEST 10 : PARTIAL 101
        //======================================================

        $display("\n========================================");
        $display("TEST 10 : PARTIAL 101");
        $display("========================================");

        apply_reset;

        apply_bit(1);
        apply_bit(0);
        apply_bit(1);

        //======================================================
        // TEST 11 : 0001011
        //======================================================

        $display("\n========================================");
        $display("TEST 11 : 0001011");
        $display("========================================");

        apply_reset;

        apply_bit(0);
        apply_bit(0);
        apply_bit(0);
        apply_bit(1);
        apply_bit(0);
        apply_bit(1);
        apply_bit(1);

        //======================================================
        // TEST 12 : OVERLAPPING 1011011
        //======================================================

        $display("\n========================================");
        $display("TEST 12 : OVERLAPPING 1011011");
        $display("========================================");

        apply_reset;

        apply_bit(1);
        apply_bit(0);
        apply_bit(1);
        apply_bit(1);
        apply_bit(0);
        apply_bit(1);
        apply_bit(1);

        //======================================================
        // TEST 13 : 111111
        //======================================================

        $display("\n========================================");
        $display("TEST 13 : 111111");
        $display("========================================");

        apply_reset;

        apply_bit(1);
        apply_bit(1);
        apply_bit(1);
        apply_bit(1);
        apply_bit(1);
        apply_bit(1);

        //======================================================
        // TEST 14 : 1000
        //======================================================

        $display("\n========================================");
        $display("TEST 14 : 1000");
        $display("========================================");

        apply_reset;

        apply_bit(1);
        apply_bit(0);
        apply_bit(0);
        apply_bit(0);

        //======================================================
        // TEST 15 : EVERY FSM TRANSITION THROUGH DUT
        //======================================================

        $display("\n========================================");
        $display("TEST 15 : EVERY FSM TRANSITION");
        $display("========================================");

        apply_reset;

        // S0 + 1 -> S1
        apply_bit(1);

        // S1 + 0 -> S2
        apply_bit(0);

        // S2 + 1 -> S3
        apply_bit(1);

        // S3 + 0 -> S2
        apply_bit(0);

        // S2 + 0 -> S0
        apply_bit(0);

        // S0 + 1 -> S1
        apply_bit(1);

        // S1 + 1 -> S1
        apply_bit(1);

        // S1 + 0 -> S2
        apply_bit(0);

        // S2 + 1 -> S3
        apply_bit(1);

        // S3 + 1 -> S1 + detection
        apply_bit(1);

        //======================================================
        // TEST 16 : RESET RECOVERY
        //======================================================

        $display("\n========================================");
        $display("TEST 16 : RESET RECOVERY");
        $display("========================================");

        apply_reset;

        apply_bit(1);
        apply_bit(0);
        apply_bit(1);

        apply_reset;

        check_2bit(
            s_state,
            S0,
            "Reset recovery state"
        );

        check_1bit(
            s_detected,
            1'b0,
            "Reset recovery detection"
        );

        //======================================================
        // TEST 17 : STRUCTURAL VS RTL
        //======================================================

        $display("\n========================================");
        $display("TEST 17 : STRUCTURAL VS RTL");
        $display("========================================");

        apply_reset;

        apply_bit(1);
        apply_bit(0);
        apply_bit(1);
        apply_bit(1);

        apply_bit(0);
        apply_bit(1);
        apply_bit(1);

        apply_bit(0);
        apply_bit(0);
        apply_bit(1);
        apply_bit(0);
        apply_bit(1);
        apply_bit(1);

        //======================================================
        // TEST 18 : REPEATED OVERLAP
        //======================================================

        $display("\n========================================");
        $display("TEST 18 : REPEATED OVERLAP");
        $display("========================================");

        apply_reset;

        // 1011011011

        apply_bit(1);
        apply_bit(0);
        apply_bit(1);
        apply_bit(1);
        apply_bit(0);
        apply_bit(1);
        apply_bit(1);
        apply_bit(0);
        apply_bit(1);
        apply_bit(1);

        //======================================================
        // FINAL RESULT
        //======================================================

        $display("\n");
        $display("================================================");
        $display("DAY 14 - 1011 SEQUENCE DETECTOR VERIFICATION");
        $display("================================================");

        $display(
            "FINAL PASS COUNT = %0d",
            pass_count
        );

        $display(
            "FINAL FAIL COUNT = %0d",
            fail_count
        );

        if(fail_count == 0) begin

            $display("================================================");
            $display("ALL TESTS PASSED");
            $display("DAY 14 VERIFICATION SUCCESSFUL");
            $display("================================================");

        end
        else begin

            $display("================================================");
            $display("VERIFICATION FAILED");
            $display("CHECK FAIL MESSAGES ABOVE");
            $display("================================================");

        end

        #20;

        $finish;

    end

    //==========================================================
    // MONITOR
    //==========================================================

    initial begin

        $monitor(
            "TIME=%0t | RESET=%b | DIN=%b | STATE=%b | NEXT=%b | STRUCT=%b | RTL=%b | MODEL=%b",
            $time,
            reset,
            test_din,
            s_state,
            s_next_state,
            s_detected,
            r_detected,
            model_detected
        );

    end

endmodule