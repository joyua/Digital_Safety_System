`timescale 1ns / 1ps

module dec2ssd(
    input [3:0] dec,       // �Է� = 10����
    output reg [6:0] seg   // ��� = 7���׸�Ʈ (gfedcba ����)
);

    always @ (*) begin
        case(dec)          // �Է� 10���� ���� ���� 7���׸�Ʈ �� �Ҵ� (gfedcba ����)
            4'd0: seg = 7'b0111111; // ���� 0
            4'd1: seg = 7'b0000110; // ���� 1
            4'd2: seg = 7'b1011011; // ���� 2
            4'd3: seg = 7'b1001111; // ���� 3
            4'd4: seg = 7'b1100110; // ���� 4
            4'd5: seg = 7'b1101101; // ���� 5
            4'd6: seg = 7'b1111101; // ���� 6
            4'd7: seg = 7'b0000111; // ���� 7
            4'd8: seg = 7'b1111111; // ���� 8
            4'd9: seg = 7'b1101111; // ���� 9
            default: seg = 7'b0111111; // �߸��� �Է� �� ���� 0 ǥ��
        endcase
    end

endmodule
