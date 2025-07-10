`timescale 1ns / 1ps
module pattern_gen(
    input clk,              // 클럭 input
    input reset_n,          // reset
    input [1:0] pattern_select, // 패턴 결정 변수 (pattern 0~2)
    
    output o_vs,            // vertical sync
    output o_hs,            // horizon sync
    
    // color data out for Zybo 7010 or Zybo 7020
    output [3:0] o_r_data,  // 4bit R(red) 0~15
    output [3:0] o_g_data,  // 4bit G(green) 0~15
    output [3:0] o_b_data   // 4bit B(blue) 0~15
    );

    // 640 x 480 // 25.2MHz @ 60Hz
    parameter h_front_porch = 32'd16;  // horizontal front porch
    parameter h_sync_width = 32'd96;   // horizontal sync pulse
    parameter h_back_porch = 32'd48;   // horizontal back porch
    parameter h_active = 32'd640;      // horizontal visible area
    
    parameter v_front_porch = 32'd10;  // vertical front porch
    parameter v_sync_width = 32'd2;    // vertical sync pulse
    parameter v_back_porch = 32'd33;   // vertical back porch
    parameter v_active = 32'd480;      // vertical visible area

    parameter h_total = h_front_porch + h_sync_width + h_back_porch + h_active; // 전체 horizontal 영역
    parameter v_total = v_front_porch + v_sync_width + v_back_porch + v_active; // 전체 vertical 영역

    parameter init_cnt_top = 32'h0000_0fff; // waiting 변수, 임의로 설정

    // Reg, Wires
    reg [31:0] init_cnt; // init_cnt_top과 같아지면 리셋 카운트
    reg [31:0] h_cnt;    // 가로 픽셀 위치

    wire h_sync_hit; 
    wire h_back_porch_hit;
    wire h_active_hit;
    wire h_front_porch_hit;

    reg [31:0] line_cnt; 
    wire active_line;

    reg vs;
    reg hs;
    reg de;

    reg [15:0] de_cnt; 

    // Structual Coding

    // Initial Waiting
    always @(posedge clk or negedge reset_n)
        if (~reset_n)
            init_cnt <= 32'b0;
        else if (init_cnt == init_cnt_top)
            init_cnt <= init_cnt;
        else
            init_cnt <= init_cnt + 1'b1;

    // horizon count
    always @(posedge clk or negedge reset_n)
        if (~reset_n)
            h_cnt <= 32'b0;
        else if (h_cnt == h_total - 1'b1)
            h_cnt <= 32'b0;
        else if (init_cnt == init_cnt_top)
            h_cnt <= h_cnt + 1'b1;

    // horizon hit point
    assign h_sync_hit = (h_cnt == h_sync_width - 1'b1) ? 1'b1 : 1'b0;
    assign h_back_porch_hit = (h_cnt == h_sync_width + h_back_porch - 1'b1) ? 1'b1 : 1'b0;
    assign h_active_hit = (h_cnt == h_sync_width + h_back_porch + h_active - 1'b1) ? 1'b1 : 1'b0;
    assign h_front_porch_hit = (h_cnt == h_sync_width + h_back_porch + h_active + h_front_porch - 1'b1) ? 1'b1 : 1'b0;

    // Vertical Count
    always @(posedge clk or negedge reset_n)
        if (~reset_n)
            line_cnt <= 32'b0;
        else if (h_front_porch_hit && (line_cnt == v_total - 1'b1))
            line_cnt <= 32'b0;
        else if (h_front_porch_hit)
            line_cnt <= line_cnt + 1'b1;

    // Vertical active line
    assign active_line = ((line_cnt > v_sync_width + v_back_porch - 1'b1) && (line_cnt < v_sync_width + v_back_porch + v_active)) ? 1'b1 : 1'b0;

    // Make VSYNC
    always @(posedge clk or negedge reset_n)
        if (~reset_n)
            vs <= 1'b0;
        else if ((line_cnt == v_total - 1'b1) && (h_front_porch_hit))
            vs <= 1'b0;
        else if ((line_cnt == v_sync_width - 1'b1) && (h_front_porch_hit))
            vs <= 1'b1;

    // Make HSYNC
    always @(posedge clk or negedge reset_n)
        if (~reset_n)
            hs <= 1'b0;
        else if (h_front_porch_hit)
            hs <= 1'b0;
        else if (h_sync_hit)
            hs <= 1'b1;

    // Make Data Enable Signal
    always @(posedge clk or negedge reset_n)
        if (~reset_n)
            de <= 1'b0;
        else if (active_line)
            if (h_back_porch_hit)
                de <= 1'b1;
        else if (h_active_hit)
            de <= 1'b0;

    assign o_vs = vs;
    assign o_hs = hs;

    // Pixel Count in Active Area
    always @(posedge clk or negedge reset_n)
        if (~reset_n)
            de_cnt <= 16'b0;
        else if (~de)
            de_cnt <= 16'b0;
        else if (de)
            de_cnt <= de_cnt + 1'b1;

    /// RGB Video Pattern Code ///
    // Pattern 0 (White Screen)
    wire p0_r_en = 1'b1;  // All red
    wire p0_g_en = 1'b1;  // All green
    wire p0_b_en = 1'b1;  // All blue (RGB 모두 최대 -> 흰색)

    // Pattern 1 (Green Screen)
    wire p1_r_en = 1'b0;  // No red
    wire p1_g_en = 1'b1;  // All green
    wire p1_b_en = 1'b0;  // No blue

    // Pattern 2 (Red Screen)
    wire p2_r_en = 1'b1;  // All red
    wire p2_g_en = 1'b0;  // No green
    wire p2_b_en = 1'b0;  // No blue

    // RGB output enable based on pattern_select
    wire r_en = (pattern_select == 2'd0) ? p0_r_en :
                (pattern_select == 2'd1) ? p1_r_en : p2_r_en;

    wire g_en = (pattern_select == 2'd0) ? p0_g_en :
                (pattern_select == 2'd1) ? p1_g_en : p2_g_en;

    wire b_en = (pattern_select == 2'd0) ? p0_b_en :
                (pattern_select == 2'd1) ? p1_b_en : p2_b_en;

    ///Color data out for Zybo 7010
    assign o_r_data = (de & r_en) ? 4'd15 : 4'b0;  // Output red color if enabled
    assign o_g_data = (de & g_en) ? 4'd15 : 4'b0;  // Output green color if enabled
    assign o_b_data = (de & b_en) ? 4'd15 : 4'b0;  // Output blue color if enabled

endmodule
