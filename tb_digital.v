`timescale 1ns / 1ps

module tb_digital();
     // Inputs
    reg clk; //25.2MHz
    reg clk_1M_tb; // 1MHz
    reg clk_ref; //100Hz
    reg up;
    reg down;
    reg rst;
    reg slide;
    reg place;
    reg PW_set;
    reg PW_endset;
    reg OK;

    // Outputs
    wire [6:0] seg_out;
    wire d_en;
    wire [3:0] sled;
    wire led6_r, led6_g;
    wire o_vs, o_hs;
    wire [3:0] o_r_data, o_g_data, o_b_data;

    // Instantiate the main module
    Digital_Safety_System uut (
        .clk(clk),
        .clk_1M_tb(clk_1M_tb),
        .clk_ref(clk_ref),
        .up(up),
        .down(down),
        .rst(rst),
        .slide(slide),
        .place(place),
        .PW_set(PW_set),
        .PW_endset(PW_endset),
        .OK(OK),
        .seg_out(seg_out),
        .d_en(d_en),
        .sled(sled),
        .led6_r(led6_r),
        .led6_g(led6_g),
        .o_vs(o_vs),
        .o_hs(o_hs),
        .o_r_data(o_r_data),
        .o_g_data(o_g_data),
        .o_b_data(o_b_data)
    );

    // Clock generation
    always #5000 clk_ref = ~clk_ref;  // 100Hz clock
    always #39.68 clk = ~clk;
    always #500 clk_1M_tb = ~clk_1M_tb;

    initial begin
        // Initialize inputs
        clk = 0;//tb용
        clk_ref = 0;
        clk_1M_tb = 0;
        up = 0;
        down = 0;
        rst = 0;
        slide = 0;
        place = 0;
        PW_set = 0;
        PW_endset = 0;
        OK = 0;
        
        // Reset the system
        #10000 rst = 1;
        #10000 rst = 0;

        // Test Case 1: Initial state and setting password
        // Test password setting
        #10000000 OK = 1; //초기 비밀번호가 0000이니 초록색 화면 뜬다.
        #100000 OK = 0;
        
        #100000 PW_set = 1; //비밀번호 설정 시작
        #100000 up = 1;
        #100000 up = 0;
        #100000 up = 1;
        #100000 up = 0;
        #100000 up = 1;
        #100000 up = 0;
        #100000 down = 1;
        #100000 down = 0; //첫째 자리수 2
        #300000 slide = 1;
        #100000 slide = 0;
        #100000 up = 1;
        #100000 up = 0; //둘쨰 자리수 1
        #300000 slide = 1;
        #100000 slide = 0; //이러면 다시 첫째 자리수로 간다. 그래서 셋째 자리수로 가기위해 place를 1로
        #300000 place = 1;// place led도 초록색에서 빨간색으로 바뀌는 것을 볼 수 있다.
        #300000 down = 1;
        #100000 down = 0;  //셋째 자리수 9
        #300000 slide = 1;
        #100000 slide = 0;
        #300000 down = 1;
        #100000 down = 0;
        #100000 down = 1;
        #100000 down = 0;  //넷째 자리수 8
        #300000 PW_endset = 1;
        #100000 PW_endset = 0;
        #100000 PW_set = 0; //비밀번호 설정 완료하여 BASIC_STATE로 돌아가서 비밀번호 확인 해보자
        #100000 place = 0; //다시 첫째 자리수로 간다.
        #300000 up = 1;
        #100000 up = 0;
        #300000 OK = 1; 
        #100000 OK = 0;
        #100000;
        $finish;
     end
endmodule