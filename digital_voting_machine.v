// ============================================================
// Digital Voting Machine with Political Party Selection
// Basys 3 FPGA (Artix-7 XC7A35T-1CPG236C)
// ============================================================
// VOTING FLOW:
//   Step 1 - Press BTNU / BTND to cycle through PARTIES (P1, P2, P3)
//   Step 2 - Flip SW[0] or SW[1] to select CANDIDATE (C1 or C2)
//   Step 3 - Press BTNC to CAST VOTE
//
//   BTNL    - Toggle Result Display (cycle through all 6 slots)
//   BTNR    - Admin Reset (clears all votes)
//
// PARTIES   : 3  (P1, P2, P3) — selected with BTNU / BTND
// CANDIDATES: 2 per party (C1, C2) — selected with SW[1:0]
// TOTAL SLOTS: 6  (P1C1, P1C2, P2C1, P2C2, P3C1, P3C2)
//
// 7-SEG DISPLAY (4 digits):
//   [Party 1-3] [Candidate 1-2] [Tens] [Ones]  <- Vote count shown in result mode
//   Decimal point ON = Result mode active
//
// LEDs:
//   LED[2:0]  = current party (one-hot: P1, P2, P3)
//   LED[4:3]  = selected candidate (one-hot: C1, C2)
//   LED[13]   = result mode ON
//   LED[14]   = invalid selection warning
//   LED[15]   = vote accepted flash
// ============================================================

module digital_voting_machine(
    input        clk,
    input        btnC,   // Cast Vote (center)
    input        btnL,   // Cycle Result View (left)
    input        btnR,   // Reset all votes (right)
    input        btnU,   // Party UP (up)
    input        btnD,   // Party DOWN (down)
    input  [1:0] sw,     // SW[0]=Candidate1, SW[1]=Candidate2
    output [6:0] seg,
    output [3:0] an,
    output       dp,
    output [15:0] led
);

    // --------------------------------------------------------
    // Vote Storage: votes[party][candidate]
    // party=0..2, candidate=0..1, max 9999
    // --------------------------------------------------------
    reg [13:0] votes [0:2][0:1];
    integer    pi, ci;

    // --------------------------------------------------------
    // Button Debounce Instances
    // --------------------------------------------------------
    wire vote_pulse, result_pulse, reset_pulse, up_pulse, dn_pulse;

    debounce db0 (.clk(clk), .btn(btnC), .pulse(vote_pulse));
    debounce db1 (.clk(clk), .btn(btnL), .pulse(result_pulse));
    debounce db2 (.clk(clk), .btn(btnR), .pulse(reset_pulse));
    debounce db3 (.clk(clk), .btn(btnU), .pulse(up_pulse));
    debounce db4 (.clk(clk), .btn(btnD), .pulse(dn_pulse));

    // --------------------------------------------------------
    // Party Selection (0=P1, 1=P2, 2=P3) via BTNU / BTND
    // --------------------------------------------------------
    reg [1:0] sel_party;

    always @(posedge clk) begin
        if (reset_pulse)
            sel_party <= 0;
        else if (up_pulse)
            sel_party <= (sel_party == 2'd2) ? 2'd0 : sel_party + 1;
        else if (dn_pulse)
            sel_party <= (sel_party == 2'd0) ? 2'd2 : sel_party - 1;
    end

    // --------------------------------------------------------
    // Candidate Selection via SW[1:0] (one-hot)
    // --------------------------------------------------------
    wire valid_vote = (sw == 2'b01 || sw == 2'b10);
    wire sel_cand   = (sw == 2'b10) ? 1'b1 : 1'b0; // 0=C1, 1=C2

    // --------------------------------------------------------
    // Vote Counting Logic
    // --------------------------------------------------------
    always @(posedge clk) begin
        if (reset_pulse) begin
            for (pi = 0; pi < 3; pi = pi + 1)
                for (ci = 0; ci < 2; ci = ci + 1)
                    votes[pi][ci] <= 14'd0;
        end else if (vote_pulse && valid_vote) begin
            if (votes[sel_party][sel_cand] < 14'd9999)
                votes[sel_party][sel_cand] <= votes[sel_party][sel_cand] + 1;
        end
    end

    // --------------------------------------------------------
    // Result View Cycling (BTNL cycles 0..5)
    // Encoding: result_view[2:1]=party, result_view[0]=candidate
    // --------------------------------------------------------
    reg [2:0] result_view;
    wire [1:0] rv_party = result_view[2:1];
    wire       rv_cand  = result_view[0];

    reg result_mode;

    always @(posedge clk) begin
        if (reset_pulse) begin
            result_view <= 3'd0;
            result_mode <= 1'b0;
        end else if (result_pulse) begin
            result_mode <= 1'b1;
            result_view <= (result_view == 3'd5) ? 3'd0 : result_view + 1;
        end else if (vote_pulse) begin
            result_mode <= 1'b0; // return to voting mode on cast
        end
    end

    // --------------------------------------------------------
    // Display Value
    // --------------------------------------------------------
    reg [13:0] display_val;
    always @(*) begin
        if (result_mode)
            display_val = votes[rv_party][rv_cand];
        else
            display_val = votes[sel_party][sel_cand]; // live preview
    end

    // --------------------------------------------------------
    // BCD Conversion (Double-Dabble, 14-bit input -> 4 BCD digits)
    // --------------------------------------------------------
    reg [3:0]  dig_thousands, dig_hundreds, dig_tens, dig_ones;
    reg [27:0] bcd_shift;
    integer    k;

    always @(*) begin
        bcd_shift = 28'd0;
        bcd_shift[13:0] = display_val;
        for (k = 0; k < 14; k = k + 1) begin
            if (bcd_shift[27:24] >= 5) bcd_shift[27:24] = bcd_shift[27:24] + 3;
            if (bcd_shift[23:20] >= 5) bcd_shift[23:20] = bcd_shift[23:20] + 3;
            if (bcd_shift[19:16] >= 5) bcd_shift[19:16] = bcd_shift[19:16] + 3;
            if (bcd_shift[15:12] >= 5) bcd_shift[15:12] = bcd_shift[15:12] + 3;
            bcd_shift = bcd_shift << 1;
        end
        dig_thousands = bcd_shift[27:24];
        dig_hundreds  = bcd_shift[23:20];
        dig_tens      = bcd_shift[19:16];
        dig_ones      = bcd_shift[15:12];
    end

    // --------------------------------------------------------
    // Flash LEDs
    // --------------------------------------------------------
    reg [22:0] flash_cnt;
    reg        flash_active;
    reg [22:0] inv_cnt;
    reg        inv_flash;

    always @(posedge clk) begin
        if (vote_pulse && valid_vote) begin
            flash_active <= 1'b1; flash_cnt <= 0;
        end else if (flash_active) begin
            if (flash_cnt == 23'h7FFFFF) begin flash_active <= 1'b0; flash_cnt <= 0; end
            else flash_cnt <= flash_cnt + 1;
        end
    end

    always @(posedge clk) begin
        if (vote_pulse && !valid_vote) begin
            inv_flash <= 1'b1; inv_cnt <= 0;
        end else if (inv_flash) begin
            if (inv_cnt == 23'h7FFFFF) begin inv_flash <= 1'b0; inv_cnt <= 0; end
            else inv_cnt <= inv_cnt + 1;
        end
    end

    // --------------------------------------------------------
    // 7-Segment Display Multiplexer (~380 Hz per digit)
    // Digit layout:
    //   AN3 (leftmost) : Party number  (1, 2, 3)
    //   AN2            : Candidate num (1, 2)
    //   AN1            : Tens  of vote count
    //   AN0 (rightmost): Ones  of vote count
    // --------------------------------------------------------
    reg [17:0] refresh_cnt;
    always @(posedge clk) refresh_cnt <= refresh_cnt + 1;

    wire [1:0] digit_sel = refresh_cnt[17:16];

    // Anode (active low)
    reg [3:0] an_reg;
    always @(*) begin
        case (digit_sel)
            2'd0: an_reg = 4'b1110;
            2'd1: an_reg = 4'b1101;
            2'd2: an_reg = 4'b1011;
            2'd3: an_reg = 4'b0111;
            default: an_reg = 4'b1111;
        endcase
    end
    assign an = an_reg;

    // 7-seg digit encoder
    function [6:0] encode_digit;
        input [3:0] d;
        case (d)
            4'd0: encode_digit = 7'b1000000;
            4'd1: encode_digit = 7'b1111001;
            4'd2: encode_digit = 7'b0100100;
            4'd3: encode_digit = 7'b0110000;
            4'd4: encode_digit = 7'b0011001;
            4'd5: encode_digit = 7'b0010010;
            4'd6: encode_digit = 7'b0000010;
            4'd7: encode_digit = 7'b1111000;
            4'd8: encode_digit = 7'b0000000;
            4'd9: encode_digit = 7'b0010000;
            default: encode_digit = 7'b1111111; // blank
        endcase
    endfunction

    // Party label: P shape for all 3, distinguished by LED
    // Using: 1=digit1, 2=digit2, 3=digit3
    function [6:0] encode_party;
        input [1:0] p;
        case (p)
            2'd0: encode_party = 7'b1111001; // "1"
            2'd1: encode_party = 7'b0100100; // "2"
            2'd2: encode_party = 7'b0110000; // "3"
            default: encode_party = 7'b1111111;
        endcase
    endfunction

    // Segment output
    reg [6:0] seg_reg;
    reg       dp_reg;

    wire [1:0] disp_party = result_mode ? rv_party : sel_party;
    wire       disp_cand  = result_mode ? rv_cand  : sel_cand;

    always @(*) begin
        dp_reg  = 1'b1; // decimal point off by default
        seg_reg = 7'b1111111;
        case (digit_sel)
            2'd3: begin // Party label
                seg_reg = encode_party(disp_party);
                dp_reg  = result_mode ? 1'b0 : 1'b1; // dp ON in result mode
            end
            2'd2: begin // Candidate label
                seg_reg = encode_digit({3'b000, disp_cand} + 4'd1);
            end
            2'd1: begin // Tens
                seg_reg = (dig_tens == 0 && dig_hundreds == 0 && dig_thousands == 0)
                          ? 7'b1111111 : encode_digit(dig_tens);
            end
            2'd0: begin // Ones
                seg_reg = encode_digit(dig_ones);
            end
        endcase
    end

    assign seg = seg_reg;
    assign dp  = dp_reg;

    // --------------------------------------------------------
    // LED Assignments
    // --------------------------------------------------------
    assign led[0]    = (sel_party == 2'd0);  // P1 active
    assign led[1]    = (sel_party == 2'd1);  // P2 active
    assign led[2]    = (sel_party == 2'd2);  // P3 active
    assign led[3]    = valid_vote & ~sel_cand; // C1 selected
    assign led[4]    = valid_vote &  sel_cand; // C2 selected
    assign led[12:5] = 8'd0;
    assign led[13]   = result_mode;
    assign led[14]   = inv_flash;
    assign led[15]   = flash_active;

endmodule


// ============================================================
// Debounce Module — 20ms @ 100 MHz
// ============================================================
module debounce(
    input  clk,
    input  btn,
    output pulse
);
    reg [20:0] cnt;
    reg        prev;
    reg        pulse_reg;

    always @(posedge clk) begin
        pulse_reg <= 1'b0;
        if (btn) begin
            if (cnt < 21'd2000000) cnt <= cnt + 1;
        end else
            cnt <= 21'd0;
        prev <= (cnt == 21'd1999999);
        if (!prev && (cnt == 21'd1999999))
            pulse_reg <= 1'b1;
    end
    assign pulse = pulse_reg;
endmodule
