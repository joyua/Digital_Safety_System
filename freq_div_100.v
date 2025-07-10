`timescale 1ns / 1ps

module freq_div_100(
    input clk_ref,          // ���� Ŭ�� �Է�
    input rst,              // ���� ��ȣ �Է�
    output reg clk_div      // ���ֵ� Ŭ�� ���
);

    reg [5:0] cnt;          // 6��Ʈ ī���� �������� (�ִ� ��: 64)

    // clk_ref�� ��� ���� �Ǵ� rst�� ��� �������� ����
    always @ (posedge clk_ref or posedge rst)
    begin
        if (rst)            // ���� ��ȣ�� Ȱ��ȭ�Ǿ��� ��
        begin
            cnt <= 6'd0;    // ī���͸� 0���� �ʱ�ȭ
            clk_div <= 1'd0; // ��� Ŭ���� 0���� �ʱ�ȭ
        end
        else
        begin
            if (cnt == 6'd49) // ī���Ͱ� 49�� �������� ��
            begin
                cnt <= 6'd0;   // ī���͸� 0���� �ʱ�ȭ
                clk_div <= ~clk_div; // ��� Ŭ���� ����Ͽ� ���ֵ� Ŭ�� ����
            end
            else
            begin
                cnt <= cnt + 6'd1; // ī���͸� 1�� ����
            end
        end
    end
endmodule
