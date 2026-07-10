module reg_file(ra, rb, rw, RFW, dataIn, dataA, dataB, clk, reset);
    input [1:0] ra, rb, rw;
    input [7:0] dataIn;
    input RFW, clk, reset;
    output reg [7:0] dataA, dataB;

    wire [7:0] dataOut0, dataOut1, dataOut2, dataOut3;

    wire enable0, enable1, enable2, enable3;

    // instantiate 4 registers
        // each register's input is already set to the desired input data
        // each register's corresponding enable is controlled by the decoder logic below
        
    reg_n_bit #(.N(8)) R0 (.D(dataIn), .Q(dataOut0), .clk(clk), .enable(enable0), .reset(reset));
    reg_n_bit #(.N(8)) R1 (.D(dataIn), .Q(dataOut1), .clk(clk), .enable(enable1), .reset(reset));
    reg_n_bit #(.N(8)) R2 (.D(dataIn), .Q(dataOut2), .clk(clk), .enable(enable2), .reset(reset));
    reg_n_bit #(.N(8)) R3 (.D(dataIn), .Q(dataOut3), .clk(clk), .enable(enable3), .reset(reset));

    parameter r0 = 2'b00, r1 = 2'b01, r2 = 2'b10, r3 = 2'b11;

    // register write is synchronous
        // decoder logic; 2-bit rw selects one of four one-hot coded outputs to select which register gets write enabled
    assign enable0 = ~rw[1] & ~rw[0] & RFW; // enable pattern: 0001 --> reg0 write enabled
    assign enable1 = ~rw[1] & rw[0] & RFW;  // enable pattern: 0010 --> reg1 write enabled
    assign enable2 = rw[1] & ~rw[0] & RFW;  // enable pattern: 0100 --> reg2 write enabled
    assign enable3 = rw[1] & rw[0] & RFW;   // enable pattern: 1000 --> reg3 write enabled 

    // register read is combinational/asynchronous 
        // regular 8-bit wide 4 to 1 mux
    always @ (*)
    begin
        dataA = 8'b0;
        case(ra)
            r0: 
                dataA = dataOut0;
            r1:
                dataA = dataOut1;
            r2:
                dataA = dataOut2;
            r3:
                dataA = dataOut3;
            default:
                dataA = 8'b0;
        endcase 

        dataB = 8'b0;
        case(rb)
            r0: 
                dataB = dataOut0;
            r1:
                dataB = dataOut1;
            r2:
                dataB = dataOut2;
            r3:
                dataB = dataOut3;
            default:
                dataB = 8'b0;
        endcase
    end
    
endmodule
