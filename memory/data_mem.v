module data_mem(clk, addr, dataIn, dataOut, memRD, memW);
    input [7:0] addr;
    input [7:0] dataIn;
    input memRD, memW, clk;
    output reg [7:0] dataOut;

    reg [7:0] RAM [0:255]; // 8-bit data, from addresses 0 to 255

    always @ (*)
    begin
        if (memRD) 
            dataOut = RAM[addr];
        else 
            dataOut = 8'd0;
    end

    always @ (posedge clk)
    begin
        if (memW)
            RAM[addr] = dataIn;
    end

endmodule
