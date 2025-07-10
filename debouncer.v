`timescale 1ns / 1ps // �ùķ��̼� �ð� ������ 1ns, �ð� ���е��� 1ps�� ����

module debouncer #(parameter N = 10,      // ī���Ͱ� N�� �����ϸ� ��ȣ�� ����ȭ
                   parameter K = 4)       // ī��Ʈ�� ��Ʈ �� (�⺻��: 4��Ʈ)
(
    input clk,             // Ŭ�� ��ȣ �Է�
    input noisy,           // ����� �ִ� �Է� ��ȣ
    output debounced       // ��ٿ�̵� ��� ��ȣ
);

    reg [K-1:0] cnt;       // K��Ʈ ī���� ��������

    // clk�� ��� �������� ����
    always @ (posedge clk) begin
        if (noisy)         // noisy ��ȣ�� Ȱ��ȭ�Ǿ��� ��
            cnt <= cnt + 1'b1; // ī���͸� 1�� ����
        else               // noisy ��ȣ�� ��Ȱ��ȭ�Ǹ� ī���͸� 0���� �ʱ�ȭ
            cnt <= 0;
    end

    // ��ٿ�̵� ��ȣ ����: ī���Ͱ� N�� �����ϸ� debounced�� 1�� ����
    assign debounced = (cnt == N) ? 1'b1 : 1'b0;

endmodule
