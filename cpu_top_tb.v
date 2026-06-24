`timescale 1ns/1ps

module cpu_top_tb;
    reg clk, reset;

    cpu_top CPU(.clk(clk), .reset(reset));

    //wire [15:0] IRdataCheck;
    //wire [7:0] RegDataCheck;

    integer i;

    ////// HELPER TASKS //////

    // RESET CPU
    task reset_CPU;
        begin
            #1;
            reset = 1;
            #5;
            reset = 0;

            $display("Reset CPU.\n");
        end
    endtask

    // CLEAR ROM
    task clear_ROM;
        begin
            for (i = 0; i < 256; i = i + 1)
                CPU.IMEM.ROM[i] = 16'd0;
            $display("ROM cleared.\n");
        end
    endtask

    // CHECK IR
    task check_IR;
        reg [15:0] IRdata;
        begin
            IRdata = CPU.IR.Q;
            $display("IR: %h", IRdata);
            $display("opcode: %b\n", CPU.FSM.opcode);
        end
    endtask

    // CHECK REGS
    task check_reg;
        // r0, r1, r2, r3, PCold, PC, MDR, A, B, ALUout
        input [3:0] reg_select;
        //output [7:0] regData;
        reg [7:0] regData;

        begin
            case(reg_select)
                4'd0: begin
                    regData = CPU.RF.R0.Q;
                    $display("r0 holds %0h\n", regData);
                end
                4'd1: begin
                    regData = CPU.RF.R1.Q;
                    $display("r1 holds %0h\n", regData);
                end
                4'd2: begin
                    regData = CPU.RF.R2.Q;
                    $display("r2 holds %0h\n", regData);
                end
                4'd3: begin
                    regData = CPU.RF.R3.Q;
                    $display("r3 holds %0h\n", regData);
                end
                4'd4: begin
                    regData = CPU.PCold.Q;
                    $display("PCold holds %0h\n", regData);
                end
                4'd5: begin
                    regData = CPU.PC.Q;
                    $display("PC holds %0h\n", regData);
                end
                4'd6: begin
                    regData = CPU.MDR.Q;
                    $display("MDR holds %0h\n", regData);
                end
                4'd7: begin
                    regData = CPU.A.Q;
                    $display("A holds %0h\n", regData);
                end
                4'd8: begin
                    regData = CPU.B.Q;
                    $display("B holds %0h\n", regData);
                end
                4'd9: begin
                    regData = CPU.ALUout.Q;
                    $display("ALUout holds %0h\n", regData);
                end
                default: $display("invalid register.\n");
            endcase
        end
    endtask

    // CHECK CURRENT CYCLE
    task check_cycle;
        $display("## CYCLE %d ##\n", CPU.FSM.cycle);
    endtask

    // CHECK NEXT CYCLE
    task check_next_cycle;
        $display("(NEXT CYCLE %d)\n", CPU.FSM.nextCycle);
    endtask

    // CHECK DMEM CONTENTS
    task check_dmem;
        input [7:0] address;
        reg [7:0] data;

        begin
            data = CPU.DMEM.RAM[address];
            $display("RAM holds %b at address %h", data, address);
        end
    endtask

    ///// TEST CASES /////

    task check_add_mov;
        begin
            reset_CPU();
            clear_ROM();

            #1;
            CPU.IMEM.ROM[0] = 16'h0503; // ldi r0, 5
            CPU.IMEM.ROM[1] = 16'h0473; // ldi r1, 4
            CPU.IMEM.ROM[2] = 16'h0014; // add r0, r1
            CPU.IMEM.ROM[3] = 16'h0082; // mov r2, r0
            CPU.IMEM.ROM[4] = 16'h000c; // jmp 0

            $display("CHECK ADD, MOV");

            $display("ldi r0, 5\nldi r1, 4\nadd r0, r1\nmov r2, r0\njmp 0\n");

            repeat(16) @ (posedge clk);

            check_reg(4'd0); // r0
            check_reg(4'd1); // r1
            check_reg(4'd2); // r2
            check_cycle();
            check_reg(4'd4); // PC
            check_reg(4'd5); // PCold

            // extra clock cycle to check jmp 0
            @ (posedge clk);
            check_cycle();
            check_reg(4'd4); // PC
            check_reg(4'd5); // PCold
        end
    endtask

    task check_load_store;
        begin
            reset_CPU();
            clear_ROM();

            #1;
            
        end

    endtask

    // INITIALIZE CLOCK
    initial
    begin
        clk = 1'b0;
        forever
        begin
            #5;
            clk = ~clk;
        end
    end

    initial 
    begin
        $dumpfile("cpu_top_tb.vcd");
        $dumpvars(0, cpu_top_tb);

        //reset_CPU();
        //clear_ROM();

        #1;
        // CPU.IMEM.ROM[0] = 16'h0503; // ldi r0, 5
        
        // CPU.IMEM.ROM[1] = 16'h0473; // ldi r1, 4
    
        // CPU.IMEM.ROM[2] = 16'h0014; // add r0, r1

        // CPU.IMEM.ROM[3] = 16'h0082; // mov r2, r0

        // CPU.IMEM.ROM[4] = 16'h000c; // jmp 0

        // //repeat(50) @ (posedge clk);
        // //@ (posedge clk)
        // #1;
        // $display("## CYCLE %d ##\n", CPU.FSM.cycle);
        // $display("memRI = %0b\nIRLd = %0b\nPColdW = %0b\n", CPU.FSM.memRI, CPU.FSM.IRLd, CPU.FSM.PColdW);
        // check_IR();
        // $display("## NEXT CYCLE %d ##\n", CPU.FSM.nextCycle);
        // check_reg(10'd32);

        // @ (posedge clk)
        // #1;
        // $display("## CYCLE %d ##\n", CPU.FSM.cycle);
        // $display("RegLd = %0b\nPCsel = %0b\nincrSel = %0b\nPCW = %0b\n", CPU.FSM.RegLd, CPU.FSM.PCsel, CPU.FSM.incrSel, CPU.FSM.PCW);
        // check_IR();
        // $display("## NEXT CYCLE %d ##\n", CPU.FSM.nextCycle);
        // check_reg(10'd32);

        // @ (posedge clk)
        // #1;
        // $display("## CYCLE %d ##\n", CPU.FSM.cycle);
        // $display("DataSel = %b\nRFW = %b\n", CPU.FSM.dataSel, CPU.FSM.RFW);
        // check_IR();
        // //check_reg(10'd1);
        // $display("regW: %d", CPU.RF.rw);
        // $display("dataIn: %h", CPU.RF.dataIn);
        // //$display("");
        // $display("## NEXT CYCLE %d ##\n", CPU.FSM.nextCycle);

        // @ (posedge clk)
        // #1;
        // $display("## CYCLE %d ##\n", CPU.FSM.cycle);
        // $display("memRI = %0b\nIRLd = %0b\nPColdW = %0b\n", CPU.FSM.memRI, CPU.FSM.IRLd, CPU.FSM.PColdW);
        // check_reg(10'd1);
        // $display("## NEXT CYCLE %d ##\n", CPU.FSM.nextCycle);

        // @ (posedge clk)
        // #1;
        // $display("## CYCLE %d ##\n", CPU.FSM.cycle);
        // $display("RegLd = %0b\nPCsel = %0b\nincrSel = %0b\nPCW = %0b\n", CPU.FSM.RegLd, CPU.FSM.PCsel, CPU.FSM.incrSel, CPU.FSM.PCW);
        // check_IR();
        // $display("## NEXT CYCLE %d ##\n", CPU.FSM.nextCycle);
        // check_reg(10'd16);

        // repeat(20) @ (posedge clk);

        // $display("## CYCLE %d ##\n", CPU.FSM.cycle);
        // $display("memRI = %0b\nIRLd = %0b\nPColdW = %0b\n", CPU.FSM.memRI, CPU.FSM.IRLd, CPU.FSM.PColdW);
        // check_IR();
        // $display("## NEXT CYCLE %d ##\n", CPU.FSM.nextCycle);


        // check_reg(10'd1);
        // check_reg(10'd2);
        // check_reg(10'd4);

        // check_reg(10'd16);
        // $display("PColdW = %d", CPU.FSM.PColdW);
        // check_reg(10'd32);
        // $display("PCW = %d", CPU.FSM.PCW);

        // CPU.IMEM.ROM[0] = 16'h0903; // ldi r0, 9
        // CPU.IMEM.ROM[1] = 16'h0173; // ldi r1, 1
        // CPU.IMEM.ROM[4] = 16'h0040; // load r2, (r0)    
        // CPU.IMEM.ROM[2] = 16'h0014; // add r0, r1

        // CPU.IMEM.ROM[3] = 16'h0082; // mov r2, r0

        // CPU.IMEM.ROM[4] = 16'h000c; // jmp 0

        // CPU.IMEM.ROM[2] = 16'h0903; // ldi r0, 9 
        // CPU.IMEM.ROM[3] = 16'h0a43; // ldi r1, 10
        // CPU.IMEM.ROM[4] = 16'h0040; // load r2, (r0)
        // CPU.IMEM.ROM[5] = 16'h00d0; // load r3, (r1)
        // CPU.IMEM.ROM[6] = 16'h00b8; // sub r2, r3
        // CPU.IMEM.ROM[7] = 16'h0081; // store r2, (r0)

        //repeat(24) @ (posedge clk);

        check_add_mov();



        $finish;




    end

endmodule