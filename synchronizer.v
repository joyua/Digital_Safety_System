`timescale 1ns / 1ps // 시뮬레이션 시간 단위를 1ns, 시간 정학도를 1ps로 설정

module synchronizer(
    input clk,             // 클럭 신호 입력
    input async_in,        // 비동기 입력 신호
    output reg sync_out    // 동기화된 출력 신호
);

    reg tmp;               // 중간 신호 저장 레지스터

    // clk의 상승 엣지에서 동작
    always @(posedge clk)
    begin
        tmp <= async_in;   // 비동기 입력을 tmp에 저장하여 1단계 지연
        sync_out <= tmp;   // tmp의 값을 동기화된 출력으로 전달
    end

endmodule
