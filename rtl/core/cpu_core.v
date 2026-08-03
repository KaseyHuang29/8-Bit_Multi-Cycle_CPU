module cpu_core(clk, reset, addrI, dataReadI, memRI, addrD, dataWriteD, dataReadD, memRD, memW);
    
    input clk, reset;

    // instruction memory
    output [7:0] addrI;
    input [15:0] dataReadI;
    output memRI;

    // data memory
    output [7:0] addrD, dataWriteD;
    input [7:0] dataReadD;
    output memRD, memW;

    // microarchitectural register signals
    wire [7:0] PCold_Q;
    wire [7:0] PC_D, PC_Q;
    wire [7:0] MDR_D, MDR_Q;
    wire [7:0] A_D, A_Q;
    wire [7:0] B_D, B_Q;
    wire [7:0] ALUout_D, ALUout_Q;
    wire [15:0] IR_D, IR_Q;

    assign addrI = PC_Q;
    assign IR_D = dataReadI;

    assign addrD = B_Q;
    assign dataWriteD = A_Q;
    assign MDR_D = dataReadD;

    // instruction register data
    wire [7:0] imm8;
    wire [1:0] ra, rb;
    wire [3:0] opcode;

    assign imm8 = IR_Q[15:8];
    assign ra = IR_Q[7:6];
    assign rb = IR_Q[5:4];
    assign opcode = IR_Q[3:0];

    // FSM control signals
    wire N, V, Z, C;
    
    wire IRLd, PColdW, RegLd, PCsel, incrSel, PCW, RFW, Bsel, ALUoutLd, flagEn, MDRLd;
    wire [2:0] ALUop;
    wire [1:0] dataSel;

    // mux output signals
    wire [7:0] selectedPC, selectedIncr; // PC selection adder inputs
    wire [7:0] selectedData; // register write data
    wire [7:0] selectedB; // ALU_B input port

    reg_n_bit #(.N(8)) PCold(.D(PC_Q), .Q(PCold_Q), .clk(clk), .enable(PColdW), .reset(reset));
    reg_n_bit #(.N(8)) PC(.D(PC_D), .Q(PC_Q), .clk(clk), .enable(PCW), .reset(reset));
    reg_n_bit #(.N(8)) MDR(.D(MDR_D), .Q(MDR_Q), .clk(clk), .enable(MDRLd), .reset(reset));
    reg_n_bit #(.N(8)) A(.D(A_D), .Q(A_Q), .clk(clk), .enable(RegLd), .reset(reset));
    reg_n_bit #(.N(8)) B(.D(B_D), .Q(B_Q), .clk(clk), .enable(RegLd), .reset(reset));
    reg_n_bit #(.N(8)) ALUout(.D(ALUout_D), .Q(ALUout_Q), .clk(clk), .enable(ALUoutLd), .reset(reset));


    two_one_mux_8bit PCSelect(.sel(PCsel), .a(PC_Q), .b(PCold_Q), .out(selectedPC));
    two_one_mux_8bit incrSelect(.sel(incrSel), .a(8'd1), .b(imm8), .out(selectedIncr));

    assign PC_D = selectedPC + selectedIncr;

    reg_n_bit #(.N(16)) IR(.D(IR_D), .Q(IR_Q), .clk(clk), .enable(IRLd), .reset(reset));

    control_fsm FSM(.clk(clk), .reset(reset), .opcode(opcode), .N(N), .Z(Z), .V(V), .C(C), .memRI(memRI), 
                    .IRLd(IRLd), .PColdW(PColdW), .RegLd(RegLd), .PCsel(PCsel), 
                    .incrSel(incrSel), .PCW(PCW), .RFW(RFW), .Bsel(Bsel), .ALUop(ALUop), 
                    .ALUoutLd(ALUoutLd), .flagEn(flagEn), .dataSel(dataSel), .MDRLd(MDRLd), 
                    .memRD(memRD), .memW(memW));

    four_one_mux_8bit DataSelect(.sel(dataSel), .a(imm8), .b(MDR_Q), .c(ALUout_Q), .d(B_Q), .out(selectedData));

    reg_file RF(.ra(ra), .rb(rb), .rw(ra), .RFW(RFW), .dataIn(selectedData), .dataA(A_D), .dataB(B_D), .clk(clk), .reset(reset));

    two_one_mux_8bit BSelect(.sel(Bsel), .a(B_Q), .b(imm8), .out(selectedB));

    alu ALU(.ALUop(ALUop), .Ain(A_Q), .Bin(selectedB), .shift2bits(rb), .Z(Z), .N(N), .V(V), .C(C), .ALUout(ALUout_D), .flagEn(flagEn));

endmodule