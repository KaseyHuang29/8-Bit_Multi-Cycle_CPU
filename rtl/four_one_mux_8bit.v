module four_one_mux_8bit(sel, a, b, c, d, out);
    input [1:0] sel;
    input [7:0] a, b, c, d;
    output reg [7:0] out;

    parameter imm8 = 2'b00, mdr = 2'b01, aluout = 2'b10, adata = 2'b11;

    always @ (*)
    begin
        case(sel)
            imm8:
                out = a;
            mdr:
                out = b;
            aluout:
                out = c;
            adata:
                out = d;
        endcase
    end

endmodule
