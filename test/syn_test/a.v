module a(
    input clk,
    input rst,
    input [3:0] a,
    output [3:0] b);

    reg [3:0] ar;
    always @(posedge clk) begin
        ar <= a;
    end

    assign b = ar;
endmodule