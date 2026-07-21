module instr_mem(addr, dataOut, memRI);
    input [7:0] addr; // 8-bit PC
    input memRI; // read enable
    output reg [15:0] dataOut;

    reg [15:0] ROM [0:255]; // 16-bit instructions, from addresses 0 to 255

    // combinational so it's asynchronous read
    always @ (*)
    begin
        if (memRI) 
            dataOut = ROM[addr];
        else 
            dataOut = 16'd0;
    end


endmodule
