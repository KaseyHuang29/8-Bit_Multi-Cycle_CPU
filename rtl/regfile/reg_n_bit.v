module reg_n_bit #(parameter N = 8)
                  (D, Q, clk, enable, reset);
    input [N - 1:0] D;
    input clk, enable, reset;
    output reg [N - 1:0] Q;

    always @ (posedge clk or posedge reset) // asynchronous reset
    // sensitivity list - ANY signal in this list that changes will trigger re-evaluation of always block
        // since we want the register to update on the posedge clk, it is inside the list
        // don't put enable in the list bc that means register values update if EITHER
        // posedge clk OR the enable edge changes. 
            // therefore, enable is just a condition inside the always block that is checked when on posedge clk 
    begin
        if (reset)
            Q <= {N{1'b0}};
        else if (enable)
            Q <= D;
        // don't need else condition; just makes explicit that if !enabled, value doesn't change
        /*
        else 
            Q <= Q; 
        */
    end

endmodule
