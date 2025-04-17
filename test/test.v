module top(
    input clk,
    input rst,

    input [7:0] a,
    input [7:0] b,
    output [7:0] c);

    reg [7:0] reg_a;
    reg [7:0] reg_b;
    reg [7:0] reg_c;

    always @(posedge clk) begin
	    reg_a <= a;
	    reg_b <= b;
	    reg_c <= a * b;
    end
    assign c = reg_c;
endmodule

/*
ABC RESULTS:             NAND2 cells:       24
ABC RESULTS:               OR2 cells:       15
ABC RESULTS:              AND2 cells:       12
Total: 51
*/

/*
ABC RESULTS:               INV cells:        1
ABC RESULTS:            NOR3_1 cells:        1
ABC RESULTS:             NAND2 cells:       23
ABC RESULTS:            NOR2_1 cells:        1
ABC RESULTS:               OR2 cells:       15
ABC RESULTS:              AND2 cells:       11
Total: 52
*/

/*
ABC RESULTS:             OR3_1 cells:        1
ABC RESULTS:             OR2_0 cells:       14
ABC RESULTS:             NAND2 cells:       22
ABC RESULTS:               OR2 cells:        7
ABC RESULTS:              AND2 cells:        7
Total: 41
*/
