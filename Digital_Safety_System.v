`timescale 1ns / 1ps
module Digital_Safety_System (
//  input clk, clk_1M_tb    //testbench �� ���� Ŭ�� 
    input clk_ref,          // ���� Ŭ�� (125MHz)
    input rst,              // ���� ��ư �Է�
    input up,               // ���� ��ư �Է�
    input down,             // ���� ��ư �Է�
    input slide,            // �ڸ��� ���� �Է�
    input place,            // ���÷��� ��ȯ ����ġ �Է� (off = 0, on = 1)
    input PW_set,           // ��й�ȣ ���� ��� ����ġ �Է� (on = 1, off = 0)
    input PW_endset,        // ��й�ȣ ���� ���� ����ġ �Է� (on = 1, off = 0)
    input OK,               // ��й�ȣ �Ǻ� Ȯ�� ����ġ �Է� (on = 1)

    output [6:0] seg_out,   // �� �ڸ��� ���÷��� ��� (�� �Ǵ� �� �� �ڸ���)
    output d_en,            // ���÷��� Ȱ��ȭ ��ȣ (1��Ʈ)
    output [3:0] sled,      // 4���� LED ���¸� ��Ÿ���� ���
    output led6_r,          // RGB LED �� ������
    output led6_g,          // RGB LED �� �ʷϻ�
    output o_vs,            // ��� ���� ����ȭ ��ȣ (Vertical Sync)
    output o_hs,            // ��� ���� ����ȭ ��ȣ (Horizontal Sync)
    output [3:0] o_r_data,  // ��� ������ ������ (4��Ʈ)
    output [3:0] o_g_data,  // ��� ��� ������ (4��Ʈ)
    output [3:0] o_b_data   // ��� �Ķ��� ������ (4��Ʈ)
);

    // ���� ����
    localparam STATE_IDLE = 2'b00;  // ��й�ȣ �Է� ��� ����
    localparam STATE_SET = 2'b01;   // ��й�ȣ ���� ����
    localparam STATE_INPUT = 2'b10; // ��й�ȣ �Է� ���� ����
    localparam STATE_CHECK = 2'b11; // ��й�ȣ Ȯ�� ����

    reg [1:0] pw_state;             // ���� ��й�ȣ ���¸� ��Ÿ���� ��������
    reg [1:0] pw_match;             // ��й�ȣ ��ġ ���θ� ��Ÿ���� 2��Ʈ ��������
    
    wire clk_125M = clk_ref;
    wire clk_25_2M, clk_100;
    wire clk_100M, clk_1M, clk_10K;
    wire s_up, s_down, s_slide; // ����ȭ�� ��ȣ
    wire d_up, d_down, d_slide; // ��ٿ�� ��ȣ

    wire [3:0] dec1, dec2, dec3, dec4;  // �� �ڸ����� ���� 4��Ʈ ��� wire Ÿ��
    reg [15:0] pw_initial;              // ����� ��й�ȣ ��������
    reg [15:0] pw_input;                // ����� �Է� ��й�ȣ ��������
    wire [1:0] state;                   // ���� ���õ� �ڸ��� ����
    wire place_state;                   // ���÷����� �ڸ��� ���� (0: �� �� �ڸ�, 1: �� �� �ڸ�)
    
//    //test bench�� clock
//    assign clk_100 = clk_ref;
//    assign clk_25_2M = clk;

    // �ʱ� ��й�ȣ ����
    initial begin
        pw_state = STATE_IDLE;           // �ʱ� ���´� ��й�ȣ ���� ��
        pw_initial = 16'b0000000000000000;  // �ʱ� ��й�ȣ�� 0000
        pw_input = 16'b0000000000000000;    // �Էµ� ��й�ȣ �ʱ�ȭ
        pw_match = 2'b00;                   // ��й�ȣ ��ġ ���� �ʱ�ȭ (�⺻: ���)
    end

    // place_state�� ����ġ�� ���¿� ���� �����˴ϴ�.
    assign place_state = place;

    // Ŭ�� ���� ��� �ν��Ͻ�
    clk_gen_25_2M clk_gen (
        .clk_ref(clk_125M),
        .rst(rst),          // ���� ��ȣ�� Ŭ�� ���� ��⿡ ����
        .clk_25_2M(clk_25_2M),
        .clk_100M(clk_100M)
    );

    // ���� ������ �ν��Ͻ�
    pattern_gen u1(
        .clk(clk_25_2M),                // �Է� Ŭ��: 25.2MHz
        .reset_n(~rst),                 // ���� ��ȣ (��Ȱ��ȭ ��ȣ�� �ʱ�ȭ�� ����)
        .pattern_select(pw_match),      // ���� ���� ��ȣ (��ġ: �ʷϻ�, ����ġ: ������, �⺻: ���)
        .o_vs(o_vs),                    // ��� ���� ����ȭ ��ȣ
        .o_hs(o_hs),                    // ��� ���� ����ȭ ��ȣ
        .o_r_data(o_r_data),            // ��� ������ ������
        .o_g_data(o_g_data),            // ��� ��� ������
        .o_b_data(o_b_data)             // ��� �Ķ��� ������
    );

    // freq_div_100 ����� ���� //testbench �� �� �ּ� ó��
    freq_div_100 f1 (.clk_ref(clk_100M), .rst(rst), .clk_div(clk_1M));
    freq_div_100 f2 (.clk_ref(clk_1M), .rst(rst), .clk_div(clk_10K));
    freq_div_100 f3 (.clk_ref(clk_10K), .rst(rst), .clk_div(clk_100));

    // Synchronizer ��� �ν��Ͻ� // testbench �� �� �ּ� ó��
    synchronizer s0 (.clk(clk_100), .async_in(up), .sync_out(s_up));
    synchronizer s1 (.clk(clk_100), .async_in(down), .sync_out(s_down));
    synchronizer s2 (.clk(clk_100), .async_in(slide), .sync_out(s_slide));

    // Debouncer ��� �ν��Ͻ� // testbench �� �� �ּ� ó�� 
    debouncer b0 (.clk(clk_100), .noisy(s_up), .debounced(d_up));
    debouncer b1 (.clk(clk_100), .noisy(s_down), .debounced(d_down));
    debouncer b2 (.clk(clk_100), .noisy(s_slide), .debounced(d_slide));

    // ���� ���� �� �� ȭ�� ��� ����
    always @(posedge clk_100 or posedge rst) begin
        if (rst) begin
            pw_state <= STATE_IDLE;  // ���� �� ��й�ȣ ��� ���·� ���ư�
            pw_match <= 2'b00;       // �⺻ ���� (��� ȭ��)
        end else begin
            case (pw_state)
                STATE_IDLE: begin
                    if (PW_set) begin
                        pw_state <= STATE_SET;  // ��й�ȣ ���� ���� ����
                    end else if (OK) begin
                        pw_state <= STATE_INPUT;  // ��й�ȣ �Է� ���� ���� ����
                    end
                    pw_match <= 2'b00;  // �⺻ ���� (��� ȭ��)
                end
                STATE_SET: begin
                    if (PW_endset) begin
                        pw_state <= STATE_IDLE;   // ��й�ȣ ���� �Ϸ� �� ��� ���·� ���ư�
                        
                    end else if (!PW_set) begin
                        pw_state <= STATE_IDLE;  // PW_set�� off�ϸ� ��� ���·� ���ư�
                    end
                end
                STATE_INPUT: begin
                    pw_input <= {dec1, dec2, dec3, dec4};  // �Էµ� ��й�ȣ ����
                    pw_state <= STATE_CHECK;  // ��й�ȣ Ȯ�� ���·� ��ȯ
                end
                STATE_CHECK: begin
                    // ��й�ȣ Ȯ�� ��忡�� ��й�ȣ ���� �� ���� ����
                    if (pw_input == pw_initial) begin
                        pw_match <= 2'b01;  // ��й�ȣ ��ġ (�ʷϻ� ȭ��)
                    end else begin
                        pw_match <= 2'b10;  // ��й�ȣ ����ġ (������ ȭ��)
                    end 
                    if (!OK) begin
                    pw_state <= STATE_IDLE;  // ���� ���� �� ��� ���·� ��ȯ
                    end
                end
                default: pw_state <= STATE_IDLE;
            endcase
        end
    end

    // ��й�ȣ ���� ó��
    always @(posedge clk_100 or posedge rst) begin
        if (rst) begin
            pw_initial <= 16'b0000000000000000;  // ���� �� �ʱ� ��й�ȣ�� 0000���� �ʱ�ȭ
        end else if (pw_state == STATE_SET && PW_endset) begin
            // ��й�ȣ ���� ��忡�� ������ �� �ڸ��� ��й�ȣ�� pw_initial�� ����
            pw_initial <= {dec1, dec2, dec3, dec4};
        end
    end
    

    // ī���� ��� �ν��Ͻ�
    up_counter_4 counter (
        .clk(clk_100),
        .rst(rst),
        .up(d_up),
        .down(d_down),
        .slide(d_slide),
        .dec1(dec1),
        .dec2(dec2),
        .dec3(dec3),
        .dec4(dec4),
        .state(state)
    );

    // 7 ���׸�Ʈ display ��� �ν��Ͻ�
    wire [6:0] d1, d2, d3, d4;  // �� �ڸ����� ���� 7-segment ���
    dec2ssd ds0 (.dec(dec1), .seg(d1));
    dec2ssd ds1 (.dec(dec2), .seg(d2));
    dec2ssd ds2 (.dec(dec3), .seg(d3));
    dec2ssd ds3 (.dec(dec4), .seg(d4));
    

    // ��Ƽ�÷����� ����� ���÷��� ���� // testbench�� �� clk_1M_tb�� Ŭ�� �ٲٱ� 
    assign seg_out = clk_1M ? ((place_state == 1'b0) ? d1 : d3) : ((place_state == 1'b0) ? d2 : d4);
    assign d_en = clk_1M;  // ���÷��� Ȱ��ȭ ��ȣ�� clk_1M�� ����� ���������� Ȱ��ȭ

    // LED ���� ����: ���� �ڸ����� ǥ���ϴ� LED �ѱ�
    assign sled[0] = (state == 2'b00); // ù ��° LED Ȱ��ȭ
    assign sled[1] = (state == 2'b01); // �� ��° LED Ȱ��ȭ
    assign sled[2] = (state == 2'b10); // �� ��° LED Ȱ��ȭ
    assign sled[3] = (state == 2'b11); // �� ��° LED Ȱ��ȭ

    // place_state�� ���� RGB LED Ȱ��ȭ
    assign led6_r = (place_state == 1'b1) ? 1'b1 : 1'b0;  // place_state�� 1�� �� ������ LED �ѱ�
    assign led6_g = (place_state == 1'b0) ? 1'b1 : 1'b0;  // place_state�� 0�� �� �ʷϻ� LED �ѱ�

endmodule
