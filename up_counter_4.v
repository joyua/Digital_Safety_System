`timescale 1ns / 1ps
module up_counter_4 (
    input clk,              // 클럭 신호
    input rst,              // 리셋 신호
    input up,               // 증가 버튼
    input down,             // 감소 버튼
    input slide,            // 자릿수 변경 버튼

    output reg [3:0] dec1,  // 첫 번째 자리 값
    output reg [3:0] dec2,  // 두 번째 자리 값
    output reg [3:0] dec3,  // 세 번째 자리 값
    output reg [3:0] dec4,  // 네 번째 자리 값
    output reg [1:0] state  // 현재 자릿수 (0: 첫째, 1: 둘째, 2: 셋째, 3: 넷째)
);

    // 초기화
    initial begin
        dec1 = 4'b0000;
        dec2 = 4'b0000;
        dec3 = 4'b0000;
        dec4 = 4'b0000;
        state = 2'b00;  // 첫 번째 자릿수 선택
    end

    // 자릿수 변경 슬라이드 처리
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= 2'b00;  // 리셋 시 첫 번째 자리로 초기화
        end else if (slide) begin
            if (state == 2'b11)
                state <= 2'b00;  // 네 번째 자릿수에서 첫 번째 자리로 순환
            else if (state == 2'b00)
                state <= 2'b01;
            else if (state == 2'b01)
                state <= 2'b10;
            else if (state == 2'b10)
                state <= 2'b11;             
        end
    end

    // 현재 선택된 자릿수에 따라 증가/감소 처리 (원형 순환)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            dec1 <= 4'b0000;
            dec2 <= 4'b0000;
            dec3 <= 4'b0000;
            dec4 <= 4'b0000;
        end else begin
            case (state)
                2'b00: begin
                    if (up)
                        dec1 <= (dec1 == 4'd9) ? 4'd0 : dec1 + 4'd1; // 9에서 0으로 순환
                    else if (down)
                        dec1 <= (dec1 == 4'd0) ? 4'd9 : dec1 - 4'd1; // 0에서 9로 순환
                end
                2'b01: begin
                    if (up)
                        dec2 <= (dec2 == 4'd9) ? 4'd0 : dec2 + 4'd1; // 9에서 0으로 순환
                    else if (down)
                        dec2 <= (dec2 == 4'd0) ? 4'd9 : dec2 - 4'd1; // 0에서 9로 순환
                end
                2'b10: begin
                    if (up)
                        dec3 <= (dec3 == 4'd9) ? 4'd0 : dec3 + 4'd1; // 9에서 0으로 순환
                    else if (down)
                        dec3 <= (dec3 == 4'd0) ? 4'd9 : dec3 - 4'd1; // 0에서 9로 순환
                end
                2'b11: begin
                    if (up)
                        dec4 <= (dec4 == 4'd9) ? 4'd0 : dec4 + 4'd1; // 9에서 0으로 순환
                    else if (down)
                        dec4 <= (dec4 == 4'd0) ? 4'd9 : dec4 - 4'd1; // 0에서 9로 순환
                end
            endcase
        end
    end

endmodule
