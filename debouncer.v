`timescale 1ns / 1ps // 시뮬레이션 시간 단위를 1ns, 시간 정학도를 1ps로 설정

module debouncer #(parameter N = 10,      // 카운터가 N에 도달하면 신호를 안정화
                   parameter K = 4)       // 카운트의 비트 수 (기본값: 4비트)
(
    input clk,             // 클럭 신호 입력
    input noisy,           // 노이즈가 있는 입력 신호
    output debounced       // 디바운싱된 출력 신호
);

    reg [K-1:0] cnt;       // K비트 카운터 레지스터

    // clk의 상승 엣지에서 동작
    always @ (posedge clk) begin
        if (noisy)         // noisy 신호가 활성화되었을 때
            cnt <= cnt + 1'b1; // 카운터를 1씩 증가
        else               // noisy 신호가 비활성화되면 카운터를 0으로 초기화
            cnt <= 0;
    end

    // 디바운싱된 신호 생성: 카운터가 N에 도달하면 debounced를 1로 설정
    assign debounced = (cnt == N) ? 1'b1 : 1'b0;

endmodule
