`timescale 1ns/1ps

module cpu_top_tb;
    reg clk, reset;

    cpu_top CPU(.clk(clk), .reset(reset));

    //wire [15:0] IRdataCheck;
    //wire [7:0] RegDataCheck;

    integer i;
    integer j;
    integer k;

    ////// HELPER TASKS //////

    task reset_CPU;
        begin
            reset = 1;
            #5.5;
            reset = 0;

            $display("CPU reset.\n");
        end
    endtask

    task clear_ROM;
        begin
            for (i = 0; i < 256; i = i + 1)
                CPU.IMEM.ROM[i] = 16'dx;
            $display("ROM cleared.\n");
        end
    endtask

    task clear_RAM;
        begin
            for (j = 0; j < 256; j = j + 1)
                CPU.DMEM.RAM[j] = 8'dx;

            $display("RAM cleared.\n");
        end
    endtask

    task check_IR;
        reg [15:0] IRdata;
        begin
            IRdata = CPU.IR.Q;
            $display("IR: %h", IRdata);
            $display("opcode: %b\n", CPU.FSM.opcode);
        end
    endtask

    task check_PCold;
        $display("PCold holds 0x%h\n", CPU.PCold.Q);
    endtask

    task check_PC;
        $display("PC holds 0x%h\n", CPU.PC.Q);
    endtask

    task check_MDR;
        $display("MDR holds 0x%h\n", CPU.MDR.Q);
    endtask

    task check_A;
        $display("A holds 0x%h\n", CPU.A.Q);
    endtask

    task check_B;
        $display("B holds 0x%h\n", CPU.B.Q);
    endtask

    task check_ALUout;
        $display("ALUout holds 0x%h\n", CPU.ALUout.Q);
    endtask

    task display_cycles;
        input [7:0] repeat_cycles;
        begin
            for (k = 0; k <= repeat_cycles; k = k + 1)
                begin
                    @ (posedge clk);
                    $display("k = %0d", k);
                    $display("Cycle = %0d   PC = %0d   IR = %h   Next Cycle = %d", CPU.FSM.cycle, CPU.PC.Q, CPU.IR.Q, CPU.FSM.nextCycle);
                    check_reg(2'd0);
                    check_reg(2'd1);
                    check_reg(2'd2);
                    check_reg(2'd3);
                    $display("\n");
                end
            $display("finished for loop");
        end
    endtask

    // CHECK REGS
    task check_reg;
        // r0, r1, r2, r3, PCold, PC, MDR, A, B, ALUout
        input [1:0] reg_select;
        //output [7:0] regData;
        reg [7:0] regData;

        begin
            case(reg_select)
                2'd0: begin
                    regData = CPU.RF.R0.Q;
                    $display("r0 holds %h\n", regData);
                end
                2'd1: begin
                    regData = CPU.RF.R1.Q;
                    $display("r1 holds %h\n", regData);
                end
                2'd2: begin
                    regData = CPU.RF.R2.Q;
                    $display("r2 holds %h\n", regData);
                end
                2'd3: begin
                    regData = CPU.RF.R3.Q;
                    $display("r3 holds %h\n", regData);
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

    // CHECK CYCLE 0 OR 1
    task check_cycle_0_1;
        begin
            if (CPU.FSM.cycle == 2'd0)
                $display("memRI = %0b\nIRLd = %0b\nPColdW = %0b\n", CPU.FSM.memRI, CPU.FSM.IRLd, CPU.FSM.PColdW);
            else if (CPU.FSM.cycle == 2'd1)
                $display("RegLd = %0b\nPCsel = %0b\nincrSel = %0b\nPCW = %0b\n", CPU.FSM.RegLd, CPU.FSM.PCsel, CPU.FSM.incrSel, CPU.FSM.PCW);
        end
    endtask

    // CHECK DMEM CONTENTS
    task check_dmem;
        input [7:0] address;
        reg [7:0] data;

        begin
            data = CPU.DMEM.RAM[address];
            $display("RAM @ 0x%h holds %b\n", address, data);
        end
    endtask

    task check_imem;
        input [7:0] address;
        reg [7:0] data;

        begin
            data = CPU.IMEM.ROM[address];
            $display("RAM @ 0x%h holds %b\n", address, data);
        end
    endtask

    task verify_reg;
        // r0, r1, r2, r3, PCold, PC, MDR, A, B, ALUout
        input [1:0] reg_select;
        input [7:0] expected_data;
        //output [7:0] regData;
        reg [7:0] regData;
        reg pass;

        begin
            case(reg_select)
                2'd0: begin
                    regData = CPU.RF.R0.Q;
                    pass = (expected_data == regData);
                end
                2'd1: begin
                    regData = CPU.RF.R1.Q;
                    pass = (expected_data == regData);
                end
                2'd2: begin
                    regData = CPU.RF.R2.Q;
                    pass = (expected_data == regData);
                end
                2'd3: begin
                    regData = CPU.RF.R3.Q;
                    pass = (expected_data == regData);
                end
                default: $display("invalid register.\n");
            endcase

            $display("Expected: r%0d holds %0d", reg_select, expected_data);
            $display("Actual: r%0d holds %0d", reg_select, regData);

            if (pass)
                    $display("PASS\n");
            else
                $display("FAIL\n");
        end
    endtask

    task verify_dmem;
        input [7:0] address;
        input [7:0] expected_data;

        reg [7:0] dmemData;
        reg pass;

        begin
            dmemData = CPU.DMEM.RAM[address];
            pass = (expected_data == dmemData);

            $display("Expected: RAM @ 0x%h holds %b", address, expected_data);
            $display("Actual: RAM @ 0x%h holds %b", address, dmemData);

            if (pass)
                $display("PASS\n");
            else
                $display("FAIL\n");
        end
    endtask

    ///// TEST CASES /////

    task test_ldi_add_mov;
        begin
            $display("### CHECK LDI, ADD, MOV ###\n");

            reset_CPU();
            clear_ROM();

            #1;
            CPU.IMEM.ROM[0] = 16'h0503; // ldi r0, 5
            CPU.IMEM.ROM[1] = 16'h0373; // ldi r1, 3
            CPU.IMEM.ROM[2] = 16'h0014; // add r0, r1
            CPU.IMEM.ROM[3] = 16'h0082; // mov r2, r0
            CPU.IMEM.ROM[4] = 16'h000c; // jmp 0

            $display("ldi r0, 5\nldi r1, 3\nadd r0, r1\nmov r2, r0\njmp 0\n");

            repeat(31) @ (posedge clk);

            //check_reg(2'd0); // r0
            //check_reg(2'd1); // r1
            //check_reg(2'd2); // r2

            verify_reg(2'd0, 8'd8);
            verify_reg(2'd1, 8'd3);
            verify_reg(2'd2, 8'd8);

            // check if on last cycle
            $display("Checking if on last cycle:");
            check_cycle();
            check_PC(); // PC
            check_PCold(); // PCold

            // extra clock cycle to check jmp 0
            $display("Extra clock cycle to check jmp 0:");
            @ (posedge clk);
            check_cycle();
            check_PC(); // PC
            check_PCold(); // PCold

            // ORIGINAL DEBUG - FIXED Z IN REG (MISSING OUTPUT SIGNAL IN DATA MUX)
            //#1;
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
        end
    endtask

    task test_load_store_sub;
        begin
            $display("### CHECK LOAD, STORE, SUB ###\n");

            reset_CPU();
            clear_ROM();
            clear_RAM();

            //check_dmem(8'd7);
            //check_dmem(8'd9);
            //check_dmem(8'd16);

            CPU.IMEM.ROM[0] = 16'h0903; // ldi r0, 9
            CPU.IMEM.ROM[1] = 16'hff42; // mov r1, r0
            CPU.IMEM.ROM[2] = 16'h0725; // addi r0, 7
            CPU.IMEM.ROM[3] = 16'h0041; // store r1, (r0)
            CPU.IMEM.ROM[4] = 16'h0311; // store r0, (r1)
            CPU.IMEM.ROM[5] = 16'h0983; // ldi r2, 9
            CPU.IMEM.ROM[6] = 16'h10c3; // ldi r3, 16
            CPU.IMEM.ROM[7] = 16'h00a0; // load r2, (r2)
            CPU.IMEM.ROM[8] = 16'h00f0; // load r3, (r3)
            CPU.IMEM.ROM[9] = 16'h00b6; // sub r2, r3
            CPU.IMEM.ROM[10] = 16'h00a1; // store r2, (r2)
            CPU.IMEM.ROM[11] = 16'h000c; // jmp 0

            $display("ldi r0, 9\nmov r1, r0\naddi r0, 7\nstore r1, (r0)\nstore r0, (r1)\nldi r2, 9\nldi r3, 16\nload r2, (r2)\nload r3, (r3)\nsub r2, r3\nstore r2, (r2)\njmp 0\n");

            #1;

            repeat(50) @ (posedge clk);

            verify_reg(2'd0, 8'd16);
            verify_reg(2'd1, 8'd9);
            verify_reg(2'd2, 8'd7);
            verify_reg(2'd3, 8'd9);

            // check_dmem(8'd7);
            // check_dmem(8'd9);
            // check_dmem(8'd16);

            verify_dmem(8'd7, 8'd7);
            verify_dmem(8'd9, 8'd16);
            verify_dmem(8'd16, 8'd9);

            /* 
            // TEDIOUS DEBUGGING
            // DEBUG RAM HOLDS 0?
            // repeat(6) @ (posedge clk);


            repeat(20) @ (posedge clk);

            check_cycle();
            check_IR();
            check_reg(2'd0);
            check_reg(2'd1);
            check_cycle_0_1();
            check_next_cycle();

            @ (posedge clk);
            check_cycle();
            check_cycle_0_1();
            check_IR();
            check_reg(2'd0);
            check_reg(2'd1);

            @ (posedge clk);
            check_cycle();
            check_cycle_0_1();
            check_IR();
            check_next_cycle();

            @ (posedge clk);
            check_cycle();
            check_cycle_0_1();
            check_IR();
            check_next_cycle();
            check_MDR();

            @ (posedge clk);
            check_cycle();
            $display("did we get here");

            @ (posedge clk);
            check_cycle();
            check_IR();
            check_cycle_0_1();

            @ (posedge clk);
            check_cycle();
            $display("memRD = %b\nMDRLd = %b", CPU.FSM.memRD, CPU.FSM.MDRLd);
            check_MDR();
            check_next_cycle();

            @ (posedge clk);
            check_cycle();
            $display("DataSel = %b\nRFW = %b", CPU.FSM.dataSel, CPU.FSM.RFW);
            check_MDR();
            check_next_cycle();

            #1;

            // r0, r1, r2, r3, PCold, PC, MDR, A, B, ALUout

            
            repeat(20) @ (posedge clk);
            check_reg(2'd0);
            check_reg(2'd1);
            check_reg(2'd2);
            check_reg(2'd3);
            */
            
        end
    endtask

    task test_OR;
        begin
            
            reset_CPU();
            clear_ROM();
            clear_RAM();

            CPU.IMEM.ROM[0] = 16'hb343; // ldi r1, 179
            CPU.IMEM.ROM[1] = 16'h6a03; // ldi r0, 106
            CPU.IMEM.ROM[2] = 16'h0092; // mov r2, r1
            CPU.IMEM.ROM[3] = 16'h0089; // or r2, r0
            CPU.IMEM.ROM[4] = 16'h000c; // jmp 0

            reset_CPU();

            $display("TEST ONLY OR\n");

            #1;

            display_cycles(20);

            verify_reg(2'd2, 8'hfb);
        end
    endtask

    task test_alu_logic;
        begin
            reset_CPU();
            clear_RAM();
            clear_ROM();

            CPU.IMEM.ROM[0]  = 16'hb343; // ldi r1, 179
            CPU.IMEM.ROM[1]  = 16'h6a03; // ldi r0, 106
            CPU.IMEM.ROM[2]  = 16'h0083; // ldi r2, 0
            CPU.IMEM.ROM[3]  = 16'h0061; // store r1, (r2)
            CPU.IMEM.ROM[4]  = 16'h0185; // addi r2, 1
            CPU.IMEM.ROM[5]  = 16'h0021; // store r0, (r2)
            CPU.IMEM.ROM[6]  = 16'h0092; // mov r2, r1
            CPU.IMEM.ROM[7]  = 16'h00e2; // mov r3, r2
            CPU.IMEM.ROM[8]  = 16'h0089; // or r2, r0
            CPU.IMEM.ROM[9]  = 16'h00fb; // not r3
            CPU.IMEM.ROM[10] = 16'h00d8; // and r3, r1
            CPU.IMEM.ROM[11] = 16'h00b1; // store r2, (r3)
            CPU.IMEM.ROM[12] = 16'h0103; // ldi r0, 1
            CPU.IMEM.ROM[13] = 16'h0000; // load r0, (r0)
            CPU.IMEM.ROM[14] = 16'h008a; // xor r2, r0
            CPU.IMEM.ROM[15] = 16'h02f3; // ldi r3, 2
            CPU.IMEM.ROM[16] = 16'h00b1; // store r2, (r3)
            CPU.IMEM.ROM[17] = 16'h000c; // jmp 0

            $display("ldi r1, 179\nldi r0, 106\nldi r2, 0\nstore r1, (r2)\naddi r2, 1\nstore r0, (r2)\nmov r2, r1\nmov r3, r2\nor r2, r0\nnot r3\nand r3, r1\nstore r2, (r3)\nldi r0, 1\nload r0, (r0)\nxor r2, r0\nldi r3, 2\nstore r2, (r3)\njmp 0\n");

            #1; 

            display_cycles(100);

            verify_reg(2'd0, 8'd106);
            verify_reg(2'd1, 8'd179);
            verify_reg(2'd2, 8'd145);
            verify_reg(2'd3, 8'd2);

            verify_dmem(8'd0, 8'd251);
            verify_dmem(8'd1, 8'd106);
            verify_dmem(8'd2, 8'd145);
        end
    endtask

    task test_alu_shift;
        begin
            reset_CPU();
            clear_RAM();
            clear_ROM();

            CPU.IMEM.ROM[0]  = 16'h6603; // ldi r0, 102
            CPU.IMEM.ROM[1]  = 16'h0227; // srli r0, 2
            CPU.IMEM.ROM[2]  = 16'hffc3; // ldi r3, 255
            CPU.IMEM.ROM[3]  = 16'h0031; // store r0, (r3)
            CPU.IMEM.ROM[4]  = 16'h6643; // ldi r1, 102
            CPU.IMEM.ROM[5]  = 16'h0557; // slli r1, 5
            CPU.IMEM.ROM[6]  = 16'hffc5; // addi r3, -1
            CPU.IMEM.ROM[7]  = 16'h0071; // store r1, (r3)
            CPU.IMEM.ROM[8]  = 16'he683; // ldi r2, 230 / -26
            CPU.IMEM.ROM[9]  = 16'h0787; // srai r2, 7
            CPU.IMEM.ROM[10] = 16'hfec5; // addi r3, -2
            CPU.IMEM.ROM[11] = 16'h00b1; // store r2, (r3)
            CPU.IMEM.ROM[12] = 16'h000c; // jmp 0

            $display("ldi r0, 102\nsrli r0, 2\nldi r3, 255\nstore r0, (r3)\nldi r1, 102\nslli r1, 5\naddi r3, -1\nstore r1, (r3)\nldi r2, 230\nsrai r2, 7\naddi r3, -2\nstore r2, (r3)\njmp 0\n");

            #2;

            display_cycles(70);

            verify_reg(2'd0, 8'd25);
            verify_reg(2'd1, 8'd192);
            verify_reg(2'd2, 8'hff);
            verify_reg(2'd3, 8'd252);

            verify_dmem(8'd255, 8'd25);
            verify_dmem(8'd254, 8'd192);
            verify_dmem(8'd252, 8'hff);

        end
    endtask

    task test_bne_taken;
        begin
            reset_CPU();
            clear_RAM();
            clear_ROM();

            CPU.IMEM.ROM[0] = 16'h0503; // ldi r0, 5
            CPU.IMEM.ROM[1] = 16'h0343; // ldi r1, 3
            CPU.IMEM.ROM[2] = 16'h031d; // bne r0, r1, 3
            CPU.IMEM.ROM[3] = 16'h0083; // ldi r2, 0
            CPU.IMEM.ROM[4] = 16'h020c; // jmp 2 
            CPU.IMEM.ROM[5] = 16'hff83; // ldi r2, 255
            CPU.IMEM.ROM[6] = 16'h000c; // jmp 0

            $display("ldi r0, 5\nldi r1, 3\nbne r0, r1, 3\nldi r2, 0\njmp 2\nldi r2, 255\njmp 0\n");

            #4;

            display_cycles(20);

            verify_reg(2'd0, 8'd5);
            verify_reg(2'd1, 8'd3);
            verify_reg(2'd2, 8'd255);
        end
    endtask

    task test_bne_untaken;
        begin
            reset_CPU();
            clear_RAM();
            clear_ROM();

            CPU.IMEM.ROM[0] = 16'h9f03; // ldi r0, 159
            CPU.IMEM.ROM[1] = 16'h9f43; // ldi r1, 159
            CPU.IMEM.ROM[2] = 16'h031d; // bne r0, r1, 3
            CPU.IMEM.ROM[3] = 16'h0083; // ldi r2, 0
            CPU.IMEM.ROM[4] = 16'h020c; // jmp 2 
            CPU.IMEM.ROM[5] = 16'hff83; // ldi r2, 255
            CPU.IMEM.ROM[6] = 16'h000c; // jmp 0

            $display("ldi r0, 5\nldi r1, 3\nbne r0, r1, 3\nldi r2, 0\njmp 2\nldi r2, 255\njmp 0\n");

            #4;

            display_cycles(20);

            verify_reg(2'd0, 8'd159);
            verify_reg(2'd1, 8'd159);
            verify_reg(2'd2, 8'd0);
        end
    endtask

    task test_bgt_pospos_taken;
        begin
            reset_CPU();
            clear_ROM();
            clear_RAM();

            CPU.IMEM.ROM[0] = 16'h7f03; // ldi r0, 127
            CPU.IMEM.ROM[1] = 16'h6f43; // ldi r1, 111
            CPU.IMEM.ROM[2] = 16'h031e; // bgt r0, r1, 3
            CPU.IMEM.ROM[3] = 16'h0083; // ldi r2, 0
            CPU.IMEM.ROM[4] = 16'h020c; // jmp 2 
            CPU.IMEM.ROM[5] = 16'hff83; // ldi r2, 255
            CPU.IMEM.ROM[6] = 16'h000c; // jmp 0

            $display("ldi r0, 127\nldi r1, 111\nbgt r0, r1, 3\nldi r2, 0\njmp 2\nldi r2, 255\njmp 0\n");

            #4;

            display_cycles(20);

            verify_reg(2'd0, 8'd127);
            verify_reg(2'd1, 8'd111);
            verify_reg(2'd2, 8'd255);

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


        // test_ldi_add_mov();

        // test_load_store_sub();

        // test_OR();

        // test_alu_logic();

        // test_alu_shift();

        // test_bne_taken();

        // test_bne_untaken();
        
        test_bgt_pospos_taken();


        $finish;

    end




endmodule