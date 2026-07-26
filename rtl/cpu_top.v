module cpu_top(clk, reset);

    input clk, reset;

    wire [7:0] instr_addr, data_addr, write_data, read_data;
    wire [15:0] read_instr;
    wire read_instr_en, read_data_en, write_data_en;

    cpu_core CORE(.clk(clk), 
                 .reset(reset), 
                 .addrI(instr_addr), 
                 .dataReadI(read_instr), 
                 .memRI(read_instr_en), 
                 .addrD(data_addr), 
                 .dataWriteD(write_data), 
                 .dataReadD(read_data), 
                 .memRD(read_data_en), 
                 .memW(write_data_en));

    instr_mem IMEM(.addr(instr_addr), 
                   .dataOut(read_instr), 
                   .memRI(read_instr_en));

    data_mem DMEM(.clk(clk), 
                  .addr(data_addr), 
                  .dataIn(write_data), 
                  .dataOut(read_data), 
                  .memRD(read_data_en), 
                  .memW(write_data_en));

endmodule