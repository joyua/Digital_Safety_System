`timescale 1ns / 1ps // �ùķ��̼� �ð� ������ 1ns, �ð� ���е��� 1ps�� ����

module synchronizer(
    input clk,             // Ŭ�� ��ȣ �Է�
    input async_in,        // �񵿱� �Է� ��ȣ
    output reg sync_out    // ����ȭ�� ��� ��ȣ
);

    reg tmp;               // �߰� ��ȣ ���� ��������

    // clk�� ��� �������� ����
    always @(posedge clk)
    begin
        tmp <= async_in;   // �񵿱� �Է��� tmp�� �����Ͽ� 1�ܰ� ����
        sync_out <= tmp;   // tmp�� ���� ����ȭ�� ������� ����
    end

endmodule
