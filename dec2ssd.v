`timescale 1ns / 1ps

module dec2ssd(
    input [3:0] dec,       // 입력 = 10진수
    output reg [6:0] seg   // 출력 = 7세그먼트 (gfedcba 순서)
);

    always @ (*) begin
        case(dec)          // 입력 10진수 값에 따른 7세그먼트 값 할당 (gfedcba 순서)
            4'd0: seg = 7'b0111111; // 숫자 0
            4'd1: seg = 7'b0000110; // 숫자 1
            4'd2: seg = 7'b1011011; // 숫자 2
            4'd3: seg = 7'b1001111; // 숫자 3
            4'd4: seg = 7'b1100110; // 숫자 4
            4'd5: seg = 7'b1101101; // 숫자 5
            4'd6: seg = 7'b1111101; // 숫자 6
            4'd7: seg = 7'b0000111; // 숫자 7
            4'd8: seg = 7'b1111111; // 숫자 8
            4'd9: seg = 7'b1101111; // 숫자 9
            default: seg = 7'b0111111; // 잘못된 입력 시 숫자 0 표시
        endcase
    end

endmodule
