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
        clk = 0;//tb��
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
        #10000000 OK = 1; //�ʱ� ��й�ȣ�� 0000�̴� �ʷϻ� ȭ�� ���.
        #100000 OK = 0;
        
        #100000 PW_set = 1; //��й�ȣ ���� ����
        #100000 up = 1;
        #100000 up = 0;
        #100000 up = 1;
        #100000 up = 0;
        #100000 up = 1;
        #100000 up = 0;
        #100000 down = 1;
        #100000 down = 0; //ù° �ڸ��� 2
        #300000 slide = 1;
        #100000 slide = 0;
        #100000 up = 1;
        #100000 up = 0; //�Ѥ� �ڸ��� 1
        #300000 slide = 1;
        #100000 slide = 0; //�̷��� �ٽ� ù° �ڸ����� ����. �׷��� ��° �ڸ����� �������� place�� 1��
        #300000 place = 1;// place led�� �ʷϻ����� ���������� �ٲ�� ���� �� �� �ִ�.
        #300000 down = 1;
        #100000 down = 0;  //��° �ڸ��� 9
        #300000 slide = 1;
        #100000 slide = 0;
        #300000 down = 1;
        #100000 down = 0;
        #100000 down = 1;
        #100000 down = 0;  //��° �ڸ��� 8
        #300000 PW_endset = 1;
        #100000 PW_endset = 0;
        #100000 PW_set = 0; //��й�ȣ ���� �Ϸ��Ͽ� BASIC_STATE�� ���ư��� ��й�ȣ Ȯ�� �غ���
        #100000 place = 0; //�ٽ� ù° �ڸ����� ����.
        #300000 up = 1;
        #100000 up = 0;
        #300000 OK = 1; 
        #100000 OK = 0;
        #100000;
        $finish;
     end
endmodule