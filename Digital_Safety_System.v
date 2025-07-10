`timescale 1ns / 1ps
module Digital_Safety_System (
//  input clk, clk_1M_tb    //testbench 때 쓰는 클락 
    input clk_ref,          // 기준 클럭 (125MHz)
    input rst,              // 리셋 버튼 입력
    input up,               // 증가 버튼 입력
    input down,             // 감소 버튼 입력
    input slide,            // 자릿수 변경 입력
    input place,            // 디스플레이 전환 스위치 입력 (off = 0, on = 1)
    input PW_set,           // 비밀번호 설정 모드 스위치 입력 (on = 1, off = 0)
    input PW_endset,        // 비밀번호 설정 종료 스위치 입력 (on = 1, off = 0)
    input OK,               // 비밀번호 판별 확인 스위치 입력 (on = 1)

    output [6:0] seg_out,   // 두 자릿수 디스플레이 출력 (앞 또는 뒤 두 자릿수)
    output d_en,            // 디스플레이 활성화 신호 (1비트)
    output [3:0] sled,      // 4개의 LED 상태를 나타내는 출력
    output led6_r,          // RGB LED 중 빨간색
    output led6_g,          // RGB LED 중 초록색
    output o_vs,            // 출력 수직 동기화 신호 (Vertical Sync)
    output o_hs,            // 출력 수평 동기화 신호 (Horizontal Sync)
    output [3:0] o_r_data,  // 출력 빨간색 데이터 (4비트)
    output [3:0] o_g_data,  // 출력 녹색 데이터 (4비트)
    output [3:0] o_b_data   // 출력 파란색 데이터 (4비트)
);

    // 상태 정의
    localparam STATE_IDLE = 2'b00;  // 비밀번호 입력 대기 상태
    localparam STATE_SET = 2'b01;   // 비밀번호 설정 상태
    localparam STATE_INPUT = 2'b10; // 비밀번호 입력 저장 상태
    localparam STATE_CHECK = 2'b11; // 비밀번호 확인 상태

    reg [1:0] pw_state;             // 현재 비밀번호 상태를 나타내는 레지스터
    reg [1:0] pw_match;             // 비밀번호 일치 여부를 나타내는 2비트 레지스터
    
    wire clk_125M = clk_ref;
    wire clk_25_2M, clk_100;
    wire clk_100M, clk_1M, clk_10K;
    wire s_up, s_down, s_slide; // 동기화된 신호
    wire d_up, d_down, d_slide; // 디바운스된 신호

    wire [3:0] dec1, dec2, dec3, dec4;  // 각 자릿수에 대한 4비트 출력 wire 타입
    reg [15:0] pw_initial;              // 저장된 비밀번호 레지스터
    reg [15:0] pw_input;                // 사용자 입력 비밀번호 레지스터
    wire [1:0] state;                   // 현재 선택된 자릿수 상태
    wire place_state;                   // 디스플레이할 자릿수 상태 (0: 앞 두 자리, 1: 뒤 두 자리)
    
//    //test bench용 clock
//    assign clk_100 = clk_ref;
//    assign clk_25_2M = clk;

    // 초기 비밀번호 설정
    initial begin
        pw_state = STATE_IDLE;           // 초기 상태는 비밀번호 세팅 전
        pw_initial = 16'b0000000000000000;  // 초기 비밀번호는 0000
        pw_input = 16'b0000000000000000;    // 입력된 비밀번호 초기화
        pw_match = 2'b00;                   // 비밀번호 일치 여부 초기화 (기본: 흰색)
    end

    // place_state는 스위치의 상태에 따라 결정됩니다.
    assign place_state = place;

    // 클럭 생성 모듈 인스턴스
    clk_gen_25_2M clk_gen (
        .clk_ref(clk_125M),
        .rst(rst),          // 리셋 신호를 클럭 생성 모듈에 적용
        .clk_25_2M(clk_25_2M),
        .clk_100M(clk_100M)
    );

    // 패턴 생성기 인스턴스
    pattern_gen u1(
        .clk(clk_25_2M),                // 입력 클럭: 25.2MHz
        .reset_n(~rst),                 // 리셋 신호 (비활성화 신호는 초기화로 설정)
        .pattern_select(pw_match),      // 패턴 선택 신호 (일치: 초록색, 불일치: 빨간색, 기본: 흰색)
        .o_vs(o_vs),                    // 출력 수직 동기화 신호
        .o_hs(o_hs),                    // 출력 수평 동기화 신호
        .o_r_data(o_r_data),            // 출력 빨간색 데이터
        .o_g_data(o_g_data),            // 출력 녹색 데이터
        .o_b_data(o_b_data)             // 출력 파란색 데이터
    );

    // freq_div_100 모듈을 분주 //testbench 할 때 주석 처리
    freq_div_100 f1 (.clk_ref(clk_100M), .rst(rst), .clk_div(clk_1M));
    freq_div_100 f2 (.clk_ref(clk_1M), .rst(rst), .clk_div(clk_10K));
    freq_div_100 f3 (.clk_ref(clk_10K), .rst(rst), .clk_div(clk_100));

    // Synchronizer 모듈 인스턴스 // testbench 할 때 주석 처리
    synchronizer s0 (.clk(clk_100), .async_in(up), .sync_out(s_up));
    synchronizer s1 (.clk(clk_100), .async_in(down), .sync_out(s_down));
    synchronizer s2 (.clk(clk_100), .async_in(slide), .sync_out(s_slide));

    // Debouncer 모듈 인스턴스 // testbench 할 때 주석 처리 
    debouncer b0 (.clk(clk_100), .noisy(s_up), .debounced(d_up));
    debouncer b1 (.clk(clk_100), .noisy(s_down), .debounced(d_down));
    debouncer b2 (.clk(clk_100), .noisy(s_slide), .debounced(d_slide));

    // 상태 전이 논리 및 화면 출력 제어
    always @(posedge clk_100 or posedge rst) begin
        if (rst) begin
            pw_state <= STATE_IDLE;  // 리셋 시 비밀번호 대기 상태로 돌아감
            pw_match <= 2'b00;       // 기본 상태 (흰색 화면)
        end else begin
            case (pw_state)
                STATE_IDLE: begin
                    if (PW_set) begin
                        pw_state <= STATE_SET;  // 비밀번호 설정 모드로 진입
                    end else if (OK) begin
                        pw_state <= STATE_INPUT;  // 비밀번호 입력 저장 모드로 진입
                    end
                    pw_match <= 2'b00;  // 기본 상태 (흰색 화면)
                end
                STATE_SET: begin
                    if (PW_endset) begin
                        pw_state <= STATE_IDLE;   // 비밀번호 설정 완료 후 대기 상태로 돌아감
                        
                    end else if (!PW_set) begin
                        pw_state <= STATE_IDLE;  // PW_set을 off하면 대기 상태로 돌아감
                    end
                end
                STATE_INPUT: begin
                    pw_input <= {dec1, dec2, dec3, dec4};  // 입력된 비밀번호 저장
                    pw_state <= STATE_CHECK;  // 비밀번호 확인 상태로 전환
                end
                STATE_CHECK: begin
                    // 비밀번호 확인 모드에서 비밀번호 검증 후 상태 변경
                    if (pw_input == pw_initial) begin
                        pw_match <= 2'b01;  // 비밀번호 일치 (초록색 화면)
                    end else begin
                        pw_match <= 2'b10;  // 비밀번호 불일치 (빨간색 화면)
                    end 
                    if (!OK) begin
                    pw_state <= STATE_IDLE;  // 상태 변경 후 대기 상태로 전환
                    end
                end
                default: pw_state <= STATE_IDLE;
            endcase
        end
    end

    // 비밀번호 설정 처리
    always @(posedge clk_100 or posedge rst) begin
        if (rst) begin
            pw_initial <= 16'b0000000000000000;  // 리셋 시 초기 비밀번호는 0000으로 초기화
        end else if (pw_state == STATE_SET && PW_endset) begin
            // 비밀번호 설정 모드에서 설정된 네 자릿수 비밀번호를 pw_initial에 저장
            pw_initial <= {dec1, dec2, dec3, dec4};
        end
    end
    

    // 카운터 모듈 인스턴스
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

    // 7 세그먼트 display 모듈 인스턴스
    wire [6:0] d1, d2, d3, d4;  // 각 자릿수에 대한 7-segment 출력
    dec2ssd ds0 (.dec(dec1), .seg(d1));
    dec2ssd ds1 (.dec(dec2), .seg(d2));
    dec2ssd ds2 (.dec(dec3), .seg(d3));
    dec2ssd ds3 (.dec(dec4), .seg(d4));
    

    // 멀티플렉싱을 사용한 디스플레이 제어 // testbench할 때 clk_1M_tb로 클락 바꾸기 
    assign seg_out = clk_1M ? ((place_state == 1'b0) ? d1 : d3) : ((place_state == 1'b0) ? d2 : d4);
    assign d_en = clk_1M;  // 디스플레이 활성화 신호를 clk_1M을 사용해 교차적으로 활성화

    // LED 상태 제어: 현재 자릿수를 표시하는 LED 켜기
    assign sled[0] = (state == 2'b00); // 첫 번째 LED 활성화
    assign sled[1] = (state == 2'b01); // 두 번째 LED 활성화
    assign sled[2] = (state == 2'b10); // 세 번째 LED 활성화
    assign sled[3] = (state == 2'b11); // 네 번째 LED 활성화

    // place_state에 따라 RGB LED 활성화
    assign led6_r = (place_state == 1'b1) ? 1'b1 : 1'b0;  // place_state가 1일 때 빨간색 LED 켜기
    assign led6_g = (place_state == 1'b0) ? 1'b1 : 1'b0;  // place_state가 0일 때 초록색 LED 켜기

endmodule
