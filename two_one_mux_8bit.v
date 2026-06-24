module two_one_mux_8bit(sel, a, b, out);
    input sel;
    input [7:0] a, b;
    output [7:0] out;

    // assign out = (a & {8{~sel}}) | (b & {8{sel}});
        // since a is 8 bits, just doing b & sel is gunna be 8'b(b) & 8'b00000001, not 8'b11111111

    assign out = sel ? b : a;

endmodule