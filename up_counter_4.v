`timescale 1ns / 1ps
module up_counter_4 (
    input clk,              // Ŭ�� ��ȣ
    input rst,              // ���� ��ȣ
    input up,               // ���� ��ư
    input down,             // ���� ��ư
    input slide,            // �ڸ��� ���� ��ư

    output reg [3:0] dec1,  // ù ��° �ڸ� ��
    output reg [3:0] dec2,  // �� ��° �ڸ� ��
    output reg [3:0] dec3,  // �� ��° �ڸ� ��
    output reg [3:0] dec4,  // �� ��° �ڸ� ��
    output reg [1:0] state  // ���� �ڸ��� (0: ù°, 1: ��°, 2: ��°, 3: ��°)
);

    // �ʱ�ȭ
    initial begin
        dec1 = 4'b0000;
        dec2 = 4'b0000;
        dec3 = 4'b0000;
        dec4 = 4'b0000;
        state = 2'b00;  // ù ��° �ڸ��� ����
    end

    // �ڸ��� ���� �����̵� ó��
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= 2'b00;  // ���� �� ù ��° �ڸ��� �ʱ�ȭ
        end else if (slide) begin
            if (state == 2'b11)
                state <= 2'b00;  // �� ��° �ڸ������� ù ��° �ڸ��� ��ȯ
            else if (state == 2'b00)
                state <= 2'b01;
            else if (state == 2'b01)
                state <= 2'b10;
            else if (state == 2'b10)
                state <= 2'b11;             
        end
    end

    // ���� ���õ� �ڸ����� ���� ����/���� ó�� (���� ��ȯ)
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
                        dec1 <= (dec1 == 4'd9) ? 4'd0 : dec1 + 4'd1; // 9���� 0���� ��ȯ
                    else if (down)
                        dec1 <= (dec1 == 4'd0) ? 4'd9 : dec1 - 4'd1; // 0���� 9�� ��ȯ
                end
                2'b01: begin
                    if (up)
                        dec2 <= (dec2 == 4'd9) ? 4'd0 : dec2 + 4'd1; // 9���� 0���� ��ȯ
                    else if (down)
                        dec2 <= (dec2 == 4'd0) ? 4'd9 : dec2 - 4'd1; // 0���� 9�� ��ȯ
                end
                2'b10: begin
                    if (up)
                        dec3 <= (dec3 == 4'd9) ? 4'd0 : dec3 + 4'd1; // 9���� 0���� ��ȯ
                    else if (down)
                        dec3 <= (dec3 == 4'd0) ? 4'd9 : dec3 - 4'd1; // 0���� 9�� ��ȯ
                end
                2'b11: begin
                    if (up)
                        dec4 <= (dec4 == 4'd9) ? 4'd0 : dec4 + 4'd1; // 9���� 0���� ��ȯ
                    else if (down)
                        dec4 <= (dec4 == 4'd0) ? 4'd9 : dec4 - 4'd1; // 0���� 9�� ��ȯ
                end
            endcase
        end
    end

endmodule
