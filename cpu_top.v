module cpu_top(clk, reset);
    input clk, reset;

    // microarchitectural register signals
    wire [7:0] PCold_Q;
    wire [7:0] PC_D, PC_Q;
    wire [7:0] MDR_D, MDR_Q;
    wire [7:0] A_D, A_Q;
    wire [7:0] B_D, B_Q;
    wire [7:0] ALUout_D, ALUout_Q;
    wire [15:0] IR_D, IR_Q;

    // instruction register data
    wire [7:0] imm8;
    wire [1:0] ra, rb;
    wire [3:0] opcode;

    assign imm8 = IR_Q[15:8];
    assign ra = IR_Q[7:6];
    assign rb = IR_Q[5:4];
    assign opcode = IR_Q[3:0];

    // FSM control signals
    wire N, V, Z;
    wire memRI, IRLd, PColdW, RegLd, PCsel, incrSel, PCW, RFW, Bsel, ALUoutLd, flagW, MDRLd, memRD, memW;
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

    instr_mem IMEM(.addr(PC_Q), .dataOut(IR_D), .memRI(memRI));
    data_mem DMEM(.clk(clk), .addr(B_Q), .dataIn(A_Q), .dataOut(MDR_D), .memRD(memRD), .memW(memW));

    control_fsm FSM(.clk(clk), .reset(reset), .opcode(opcode), .N(N), .Z(Z), .V(V), .memRI(memRI), 
                    .IRLd(IRLd), .PColdW(PColdW), .RegLd(RegLd), .PCsel(PCsel), 
                    .incrSel(incrSel), .PCW(PCW), .RFW(RFW), .Bsel(Bsel), .ALUop(ALUop), 
                    .ALUoutLd(ALUoutLd), .flagW(flagW), .dataSel(dataSel), .MDRLd(MDRLd), 
                    .memRD(memRD), .memW(memW));

    four_one_mux_8bit DataSelect(.sel(dataSel), .a(imm8), .b(MDR_Q), .c(ALUout_Q), .d(B_Q), .out(selectedData));

    reg_file RF(.ra(ra), .rb(rb), .rw(ra), .RFW(RFW), .dataIn(selectedData), .dataA(A_D), .dataB(B_D), .clk(clk), .reset(reset));

    two_one_mux_8bit BSelect(.sel(Bsel), .a(B_Q), .b(imm8), .out(selectedB));

    alu ALU(.ALUop(ALUop), .Ain(A_Q), .Bin(selectedB), .shift2bits(rb), .Z(Z), .N(N), .V(V), .ALUout(ALUout_D), .flagW(flagW));

endmodule