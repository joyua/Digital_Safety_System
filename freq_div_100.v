`timescale 1ns / 1ps

module freq_div_100(
    input clk_ref,          // 기준 클럭 입력
    input rst,              // 리셋 신호 입력
    output reg clk_div      // 분주된 클럭 출력
);

    reg [5:0] cnt;          // 6비트 카운터 레지스터 (최대 값: 64)

    // clk_ref의 상승 엣지 또는 rst의 상승 엣지에서 동작
    always @ (posedge clk_ref or posedge rst)
    begin
        if (rst)            // 리셋 신호가 활성화되었을 때
        begin
            cnt <= 6'd0;    // 카운터를 0으로 초기화
            clk_div <= 1'd0; // 출력 클럭을 0으로 초기화
        end
        else
        begin
            if (cnt == 6'd49) // 카운터가 49에 도달했을 때
            begin
                cnt <= 6'd0;   // 카운터를 0으로 초기화
                clk_div <= ~clk_div; // 출력 클럭을 토글하여 분주된 클럭 생성
            end
            else
            begin
                cnt <= cnt + 6'd1; // 카운터를 1씩 증가
            end
        end
    end
endmodule
