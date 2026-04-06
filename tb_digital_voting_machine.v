// ============================================================
// Testbench — Digital Voting Machine
// Simulates button presses, party/candidate selection, voting
// and result display cycling
// Run in Vivado Simulator or ModelSim
// ============================================================

`timescale 1ns / 1ps

module tb_digital_voting_machine;

    // --------------------------------------------------------
    // Inputs (driven by testbench)
    // --------------------------------------------------------
    reg        clk;
    reg        btnC, btnL, btnR, btnU, btnD;
    reg  [1:0] sw;

    // --------------------------------------------------------
    // Outputs (observed)
    // --------------------------------------------------------
    wire [6:0] seg;
    wire [3:0] an;
    wire       dp;
    wire [15:0] led;

    // --------------------------------------------------------
    // Instantiate the DUT (Device Under Test)
    // --------------------------------------------------------
    digital_voting_machine uut (
        .clk  (clk),
        .btnC (btnC),
        .btnL (btnL),
        .btnR (btnR),
        .btnU (btnU),
        .btnD (btnD),
        .sw   (sw),
        .seg  (seg),
        .an   (an),
        .dp   (dp),
        .led  (led)
    );

    // --------------------------------------------------------
    // Clock Generation — 100 MHz (10 ns period)
    // --------------------------------------------------------
    initial clk = 0;
    always #5 clk = ~clk;  // toggle every 5ns

    // --------------------------------------------------------
    // Task: Press a button for 25ms then release
    // (longer than 20ms debounce threshold)
    // --------------------------------------------------------
    task press_button;
        input reg btn_signal; // not synthesizable but ok for TB
        // We directly drive buttons in each test case
    endtask

    // Debounce requires 2,000,000 cycles @ 100MHz = 20ms
    // In simulation we use a shorter version: 2,100,000 cycles
    // to ensure pulse fires
    integer i;

    // --------------------------------------------------------
    // Helper task: simulate button press (hold for 2.1M cycles)
    // --------------------------------------------------------
    task sim_press;
        inout reg btn;
        begin
            btn = 1;
            repeat(2100000) @(posedge clk); // hold > 20ms
            btn = 0;
            repeat(100) @(posedge clk);     // small gap after
        end
    endtask

    // --------------------------------------------------------
    // Main Test Sequence
    // --------------------------------------------------------
    initial begin
        // Initialize all inputs
        btnC = 0; btnL = 0; btnR = 0;
        btnU = 0; btnD = 0;
        sw   = 2'b00;

        // Wait for global reset
        repeat(100) @(posedge clk);

        $display("==============================================");
        $display(" Digital Voting Machine — Simulation Start");
        $display("==============================================");

        // ------------------------------------------------
        // TEST 1: Reset everything first
        // ------------------------------------------------
        $display("\n[TEST 1] Pressing BTNR to reset all votes...");
        sim_press(btnR);
        $display("  -> Reset done. All votes should be 0.");
        repeat(200) @(posedge clk);

        // ------------------------------------------------
        // TEST 2: Vote for Party 1, Candidate 1
        // Default party = P1, just flip SW[0]
        // ------------------------------------------------
        $display("\n[TEST 2] Voting P1-C1 (SW[0]=1, press BTNC)");
        sw = 2'b01;            // Select Candidate 1
        repeat(100) @(posedge clk);
        sim_press(btnC);       // Cast vote
        $display("  -> LED[15] should flash (vote accepted)");
        $display("  -> LED[0]  should be ON (Party 1)");
        $display("  -> LED[3]  should be ON (Candidate 1)");
        repeat(500) @(posedge clk);

        // ------------------------------------------------
        // TEST 3: Vote for Party 1, Candidate 1 again (count=2)
        // ------------------------------------------------
        $display("\n[TEST 3] Voting P1-C1 again (count should be 2)");
        sim_press(btnC);
        repeat(500) @(posedge clk);

        // ------------------------------------------------
        // TEST 4: Move to Party 2 using BTNU
        // ------------------------------------------------
        $display("\n[TEST 4] Pressing BTNU to select Party 2...");
        sw = 2'b00;            // clear switches first
        repeat(100) @(posedge clk);
        sim_press(btnU);       // Party 1 -> Party 2
        $display("  -> Display leftmost digit should show '2'");
        $display("  -> LED[1] should be ON (Party 2)");
        repeat(200) @(posedge clk);

        // ------------------------------------------------
        // TEST 5: Vote for Party 2, Candidate 2
        // ------------------------------------------------
        $display("\n[TEST 5] Voting P2-C2 (SW[1]=1, press BTNC)");
        sw = 2'b10;            // Select Candidate 2
        repeat(100) @(posedge clk);
        sim_press(btnC);
        $display("  -> LED[15] should flash");
        $display("  -> LED[4]  should be ON (Candidate 2)");
        repeat(500) @(posedge clk);

        // ------------------------------------------------
        // TEST 6: Invalid vote test (both switches ON)
        // ------------------------------------------------
        $display("\n[TEST 6] Invalid vote test (SW=11, both ON)");
        sw = 2'b11;
        repeat(100) @(posedge clk);
        sim_press(btnC);
        $display("  -> LED[14] should flash (invalid warning)");
        $display("  -> Vote should NOT be counted");
        repeat(500) @(posedge clk);

        // ------------------------------------------------
        // TEST 7: Invalid vote test (no switches)
        // ------------------------------------------------
        $display("\n[TEST 7] Invalid vote test (SW=00, none ON)");
        sw = 2'b00;
        repeat(100) @(posedge clk);
        sim_press(btnC);
        $display("  -> LED[14] should flash (invalid warning)");
        repeat(500) @(posedge clk);

        // ------------------------------------------------
        // TEST 8: Move to Party 3 using BTNU twice
        // ------------------------------------------------
        $display("\n[TEST 8] Moving to Party 3 (press BTNU twice)");
        sim_press(btnU); // P2 -> P3
        repeat(200) @(posedge clk);
        $display("  -> Display should show '3'");
        $display("  -> LED[2] should be ON");

        // ------------------------------------------------
        // TEST 9: Vote Party 3, Candidate 1 three times
        // ------------------------------------------------
        $display("\n[TEST 9] Voting P3-C1 x3");
        sw = 2'b01;
        repeat(100) @(posedge clk);
        sim_press(btnC);
        repeat(300) @(posedge clk);
        sim_press(btnC);
        repeat(300) @(posedge clk);
        sim_press(btnC);
        $display("  -> P3-C1 vote count should be 3");
        repeat(500) @(posedge clk);

        // ------------------------------------------------
        // TEST 10: Enter Result Mode and cycle through slots
        // ------------------------------------------------
        $display("\n[TEST 10] Entering result mode (press BTNL)");
        sw = 2'b00;
        repeat(100) @(posedge clk);
        sim_press(btnL);
        $display("  -> Result mode ON, LED[13] should glow");
        $display("  -> Decimal point ON on display");
        $display("  -> Showing P1-C1 = 2 votes");
        repeat(300) @(posedge clk);

        sim_press(btnL);
        $display("  -> Now showing P1-C2 = 0 votes");
        repeat(300) @(posedge clk);

        sim_press(btnL);
        $display("  -> Now showing P2-C1 = 0 votes");
        repeat(300) @(posedge clk);

        sim_press(btnL);
        $display("  -> Now showing P2-C2 = 1 vote");
        repeat(300) @(posedge clk);

        sim_press(btnL);
        $display("  -> Now showing P3-C1 = 3 votes");
        repeat(300) @(posedge clk);

        sim_press(btnL);
        $display("  -> Now showing P3-C2 = 0 votes");
        repeat(300) @(posedge clk);

        // ------------------------------------------------
        // TEST 11: Party DOWN test
        // ------------------------------------------------
        $display("\n[TEST 11] Testing BTND (party down)");
        sim_press(btnR);  // reset first
        repeat(200) @(posedge clk);
        sim_press(btnD);  // P1 -> P3 (wraps down)
        $display("  -> Display should show '3' (wrapped to P3)");
        repeat(300) @(posedge clk);
        sim_press(btnD);  // P3 -> P2
        $display("  -> Display should show '2'");
        repeat(300) @(posedge clk);
        sim_press(btnD);  // P2 -> P1
        $display("  -> Display should show '1'");
        repeat(300) @(posedge clk);

        // ------------------------------------------------
        // TEST 12: Final Reset
        // ------------------------------------------------
        $display("\n[TEST 12] Final reset test");
        sim_press(btnR);
        $display("  -> All votes cleared to 0");
        repeat(500) @(posedge clk);

        // ------------------------------------------------
        // End of simulation
        // ------------------------------------------------
        $display("\n==============================================");
        $display(" Simulation Complete!");
        $display(" Check waveforms in Vivado for visual verify");
        $display("==============================================");
        $finish;
    end

    // --------------------------------------------------------
    // Monitor — prints whenever LED or display changes
    // --------------------------------------------------------
    initial begin
        $monitor("Time=%0t | LED=%b | AN=%b | SEG=%b | DP=%b",
                  $time, led, an, seg, dp);
    end

    // --------------------------------------------------------
    // Waveform dump (for GTKWave or Vivado waveform viewer)
    // --------------------------------------------------------
    initial begin
        $dumpfile("voting_machine_sim.vcd");
        $dumpvars(0, tb_digital_voting_machine);
    end

endmodule
