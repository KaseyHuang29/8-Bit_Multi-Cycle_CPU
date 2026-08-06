`timescale 1ns/1ps

module alu_tb;
    // declare DUT inputs as reg
    reg [2:0] ALUop;
    reg [7:0] Ain, Bin;
    reg [1:0] shift2bits;
    reg flagEn;

    // declare DUT outputs as wire 
    wire Z, N, V, C;
    wire [7:0] ALUout;

    // instantiate the DUT (alu)
    alu a(.ALUop(ALUop), 
          .Ain(Ain), 
          .Bin(Bin), 
          .shift2bits(shift2bits), 
          .Z(Z), 
          .N(N), 
          .V(V), 
          .C(C),
          .ALUout(ALUout),
          .flagEn(flagEn));

    // pass/fail flag for expected output 
    parameter TEST_TOTAL = 26;
    reg [TEST_TOTAL-1:0] pass;
    reg E_Z, E_N, E_V, E_C;
    reg [7:0] E_ALUout;

    // test summary
    reg [TEST_TOTAL-1:0] new_pass;
    wire [TEST_TOTAL-1:0] pass_mask;
    reg [4:0] pass_count;
    assign pass_mask = 1;
    integer i;

    initial 
    begin
        // tell simulator what waveform file to create
            // .vcd file shows the waveforms in GTKWave
        $dumpfile("tb/alu_tb.vcd");

        // tell simulator which signals to record in the waveform file
            // 0 means dump everything under alu_tb and all hierarchy levels
            // 1 means dump only signals under alu_tb, but not signals inside instantiated modules
        $dumpvars(0, alu_tb);

        flagEn = 1;

        $display("## ADDITION TEST CASES ## \n");

        // regular addition
        $display("regular addition");

        // expected output
        E_N = 0;
        E_V = 0;
        E_Z = 0;
        E_ALUout = 8'b01001011;

        // input
        Ain = 8'd45;
        Bin = 8'd30;
        ALUop = 3'b000;
        #10; // wait 10 ns between each case

        $display("Expected Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, E_ALUout, E_ALUout, E_Z, E_N, E_V);

        $display("Actual Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, ALUout, ALUout, Z, N, V);
        
        pass[0] = (E_Z == Z) & (E_N == N) & (E_V == V) & (E_ALUout == ALUout);

        if (pass[0])
            $display("PASS\n");
        else
            $display("FAIL\n");


        // positive overflow addition
        $display("positive overflow addition");

        // expected output
        E_N = 1;
        E_V = 1;
        E_Z = 0;
        E_ALUout = 8'b10000001;

        // input
        Ain = 8'd64;
        Bin = 8'd65;
        ALUop = 3'b000;
        #10;

        $display("Expected Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, E_ALUout, E_ALUout, E_Z, E_N, E_V);

        $display("Actual Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, ALUout, ALUout, Z, N, V);

        pass[1] = (E_Z == Z) & (E_N == N) & (E_V == V) & (E_ALUout == ALUout);

        if (pass[1])
            $display("PASS\n");
        else
            $display("FAIL\n");

        // negative overflow addition
        $display("negative overflow addition");

        // expected output
        E_N = 0;
        E_V = 1;
        E_Z = 0;
        E_ALUout = 8'b01111111;

        // input
        Ain = 8'd255;
        Bin = 8'd128;
        ALUop = 3'b000;
        #10;

        $display("Expected Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, E_ALUout, E_ALUout, E_Z, E_N, E_V);

        $display("Actual Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, ALUout, ALUout, Z, N, V);

        pass[2] = (E_Z == Z) & (E_N == N) & (E_V == V) & (E_ALUout == ALUout);

        if (pass[2])
            $display("PASS\n");
        else
            $display("FAIL\n");


        $display("## SUBTRACTION TEST CASES ## \n");

        // regular subtraction
        $display("regular subtraction\n");

        // expected output
        E_N = 0;
        E_V = 0;
        E_Z = 0;
        E_ALUout = 8'b00001111;

        // input
        Ain = 8'd45;
        Bin = 8'd30;
        ALUop = 3'b001;
        #10;

        $display("Expected Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, E_ALUout, E_ALUout, E_Z, E_N, E_V);

        $display("Actual Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, ALUout, ALUout, Z, N, V);

        pass[3] = (E_Z == Z) & (E_N == N) & (E_V == V) & (E_ALUout == ALUout);
    
        if (pass[3])
            $display("PASS\n");
        else
            $display("FAIL\n");

        // negative result subtraction

        $display("negative result subtraction");

        // expected output
        E_N = 1;
        E_V = 0;
        E_Z = 0;
        E_ALUout = 8'b11110001;

        // input
        Ain = 8'd30;
        Bin = 8'd45;
        ALUop = 3'b001;
        #10;

        $display("Expected Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, E_ALUout, E_ALUout, E_Z, E_N, E_V);

        $display("Actual Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, ALUout, ALUout, Z, N, V);

        pass[4] = (E_Z == Z) & (E_N == N) & (E_V == V) & (E_ALUout == ALUout);
    
        if (pass[4])
            $display("PASS\n");
        else
            $display("FAIL\n");

        // negative number subtraction 

        $display("negative number subtraction");

        // expected output
        E_N = 0;
        E_V = 0;
        E_Z = 0;
        E_ALUout = 8'b01011010;

        // input
        Ain = 8'd45;
        Bin = 8'd211;   // -45
        ALUop = 3'b001;
        #10;

        $display("Expected Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, E_ALUout, E_ALUout, E_Z, E_N, E_V);

        $display("Actual Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, ALUout, ALUout, Z, N, V);

        pass[5] = (E_Z == Z) & (E_N == N) & (E_V == V) & (E_ALUout == ALUout);
    
        if (pass[5])
            $display("PASS\n");
        else
            $display("FAIL\n");

        // zero result 

        $display("zero result subtraction");

        // expected output
        E_N = 0;
        E_V = 0;
        E_Z = 1;
        E_ALUout = 8'b00000000;

        // input
        Ain = 8'd45;
        Bin = 8'd45;
        ALUop = 3'b001;
        #10;

        $display("Expected Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, E_ALUout, E_ALUout, E_Z, E_N, E_V);

        $display("Actual Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, ALUout, ALUout, Z, N, V);

        pass[6] = (E_Z == Z) & (E_N == N) & (E_V == V) & (E_ALUout == ALUout);
    
        if (pass[6])
            $display("PASS\n");
        else
            $display("FAIL\n");

        // positive overflow

        $display("positive overflow subtraction\n");

        // expected output
        E_N = 1;
        E_V = 1;
        E_Z = 0; 
        E_ALUout = 8'b10000000;

        // input
        Ain = 8'd127;
        Bin = 8'd255;   // -1
        ALUop = 3'b001;
        #10;

        $display("Expected Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, E_ALUout, E_ALUout, E_Z, E_N, E_V);

        $display("Actual Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, ALUout, ALUout, Z, N, V);

        pass[7] = (E_Z == Z) & (E_N == N) & (E_V == V) & (E_ALUout == ALUout);
    
        if (pass[7])
            $display("PASS\n");
        else
            $display("FAIL\n");
        // negative overflow

        $display("negative overflow subtraction\n");

        // expected output
        E_N = 0;
        E_V = 1;
        E_Z = 0;
        E_ALUout = 8'b01111111;

        // input
        Ain = 8'd128;   // -128
        Bin = 8'd1;
        ALUop = 3'b001;
        #10;

        $display("Expected Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, E_ALUout, E_ALUout, E_Z, E_N, E_V);

        $display("Actual Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, ALUout, ALUout, Z, N, V);

        pass[8] = (E_Z == Z) & (E_N == N) & (E_V == V) & (E_ALUout == ALUout);
    
        if (pass[8])
            $display("PASS\n");
        else
            $display("FAIL\n");

        $display("## SHIFT TEST CASES ## \n");

        // left logical shift

        $display("left logical shift\n");

        // expected output
        E_N = 0;
        E_V = 0;
        E_Z = 0;
        E_ALUout = 8'b00001000;

        // input
        Ain = 8'd4;
        Bin = 3'b001;
        shift2bits = 2'b11;
        ALUop = 3'b010;
        #10;

        $display("Expected Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, E_ALUout, E_ALUout, E_Z, E_N, E_V);

        $display("Actual Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, ALUout, ALUout, Z, N, V);

        pass[9] = (E_Z == Z) & (E_N == N) & (E_V == V) & (E_ALUout == ALUout);
    
        if (pass[9])
            $display("PASS\n");
        else
            $display("FAIL\n");

        // left logical full shift

        $display("left logical full shift\n");

        // expected output
        E_N = 1;
        E_V = 0;
        E_Z = 0;
        E_ALUout = 8'b10000000;

        // input
        Ain = 8'd1;
        Bin = 3'b111;
        shift2bits = 2'b11;
        ALUop = 3'b010;
        #10;

        $display("Expected Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, E_ALUout, E_ALUout, E_Z, E_N, E_V);

        $display("Actual Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, ALUout, ALUout, Z, N, V);

        pass[10] = (E_Z == Z) & (E_N == N) & (E_V == V) & (E_ALUout == ALUout);
    
        if (pass[10])
            $display("PASS\n");
        else
            $display("FAIL\n");        

        // right logical shift

        $display("right logical shift\n");

        // expected output
        E_N = 0;
        E_V = 0;
        E_Z = 0;
        E_ALUout = 8'b00001000;

        // input
        Ain = 8'd16;
        Bin = 3'b001;
        shift2bits = 2'b10;
        ALUop = 3'b010;
        #10;

        $display("Expected Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, E_ALUout, E_ALUout, E_Z, E_N, E_V);

        $display("Actual Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, ALUout, ALUout, Z, N, V);

        pass[11] = (E_Z == Z) & (E_N == N) & (E_V == V) & (E_ALUout == ALUout);
    
        if (pass[11])
            $display("PASS\n");
        else
            $display("FAIL\n");

        // right logical full shift

        $display("right logical full shift\n");

        // expected output
        E_N = 0;
        E_V = 0;
        E_Z = 0;
        E_ALUout = 8'b00000001;

        // input
        Ain = 8'd128;
        Bin = 3'b111;
        shift2bits = 2'b10;
        ALUop = 3'b010;
        #10;   

        $display("Expected Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, E_ALUout, E_ALUout, E_Z, E_N, E_V);

        $display("Actual Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, ALUout, ALUout, Z, N, V);

        pass[12] = (E_Z == Z) & (E_N == N) & (E_V == V) & (E_ALUout == ALUout);
    
        if (pass[12])
            $display("PASS\n");
        else
            $display("FAIL\n");

        // positive right arithmetic shift

        $display("positive right arithmetic shift\n");

        // expected output
        E_N = 0;
        E_V = 0;
        E_Z = 0;
        E_ALUout = 8'b00000100;

        // input
        Ain = 8'd32;
        Bin = 3'b011;
        shift2bits = 2'b00;
        ALUop = 3'b010;
        #10;

        $display("Expected Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, E_ALUout, E_ALUout, E_Z, E_N, E_V);

        $display("Actual Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, ALUout, ALUout, Z, N, V);

        pass[13] = (E_Z == Z) & (E_N == N) & (E_V == V) & (E_ALUout == ALUout);
    
        if (pass[13])
            $display("PASS\n");
        else
            $display("FAIL\n");

        // negative right arithmetic shift

        $display("negative right arithmetic shift\n");

        // expected output
        E_N = 1;
        E_V = 0;
        E_Z = 0;
        E_ALUout = 8'b11111100;

        // input
        Ain = 8'd224;
        Bin = 3'b011;
        shift2bits = 2'b00;
        ALUop = 3'b010;
        #10;

        $display("Expected Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, E_ALUout, E_ALUout, E_Z, E_N, E_V);

        $display("Actual Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, ALUout, ALUout, Z, N, V);

        pass[14] = (E_Z == Z) & (E_N == N) & (E_V == V) & (E_ALUout == ALUout);
    
        if (pass[14])
            $display("PASS\n");
        else
            $display("FAIL\n");

        $display("## AND TEST CASES ## \n");

        // preserves all AND

        $display("preserves all AND\n");

        // expected output 
        E_N = 0;
        E_V = 0;
        E_Z = 0;
        E_ALUout = 8'b00011110;

        // input
        Ain = 8'd30;
        Bin = 8'd255; 
        ALUop = 3'b011;
        #10;

        $display("Expected Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, E_ALUout, E_ALUout, E_Z, E_N, E_V);

        $display("Actual Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, ALUout, ALUout, Z, N, V);

        pass[15] = (E_Z == Z) & (E_N == N) & (E_V == V) & (E_ALUout == ALUout);
    
        if (pass[15])
            $display("PASS\n");
        else
            $display("FAIL\n");

        // preserves none AND

        $display("preserves none AND\n");

        // expected output
        E_N = 0;
        E_V = 0;
        E_Z = 1;
        E_ALUout = 8'b00000000;

        // input
        Ain = 8'd30;
        Bin = 8'd0;
        ALUop = 3'b011;
        #10;

        $display("Expected Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, E_ALUout, E_ALUout, E_Z, E_N, E_V);

        $display("Actual Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, ALUout, ALUout, Z, N, V);

        pass[16] = (E_Z == Z) & (E_N == N) & (E_V == V) & (E_ALUout == ALUout);
    
        if (pass[16])
            $display("PASS\n");
        else
            $display("FAIL\n");

        // regular AND

        $display("regular AND\n");

        // expected output
        E_N = 1;
        E_V = 0;
        E_Z = 0;
        E_ALUout = 8'b10001010;

        // input
        Ain = 8'd158;
        Bin = 8'd170;
        ALUop = 3'b011;
        #10;

        $display("Expected Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, E_ALUout, E_ALUout, E_Z, E_N, E_V);

        $display("Actual Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, ALUout, ALUout, Z, N, V);

        pass[17] = (E_Z == Z) & (E_N == N) & (E_V == V) & (E_ALUout == ALUout);
    
        if (pass[17])
            $display("PASS\n");
        else
            $display("FAIL\n");

        $display("## OR TEST CASES ## \n");

        // regular OR

        $display("regular OR\n");

        // expected output
        E_N = 0;
        E_V = 0;
        E_Z = 0;
        E_ALUout = 8'b01111101;

        // input
        Ain = 8'd53;
        Bin = 8'd109;
        ALUop = 3'b100;
        #10;

        $display("Expected Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, E_ALUout, E_ALUout, E_Z, E_N, E_V);

        $display("Actual Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, ALUout, ALUout, Z, N, V);

        pass[18] = (E_Z == Z) & (E_N == N) & (E_V == V) & (E_ALUout == ALUout);
    
        if (pass[18])
            $display("PASS\n");
        else
            $display("FAIL\n");

        $display("## XOR TEST CASES ## \n");

        // regular XOR
        $display("regular XOR\n");

        // expected output
        E_N = 0;
        E_V = 0;
        E_Z = 0;
        E_ALUout = 8'b01011110;

        // input 
        Ain = 8'd53;
        Bin = 8'd107;
        ALUop = 3'b101;
        #10;

        $display("Expected Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, E_ALUout, E_ALUout, E_Z, E_N, E_V);

        $display("Actual Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, ALUout, ALUout, Z, N, V);

        pass[19] = (E_Z == Z) & (E_N == N) & (E_V == V) & (E_ALUout == ALUout);
    
        if (pass[19])
            $display("PASS\n");
        else
            $display("FAIL\n");

        // zero result XOR
        $display("zero result XOR\n");

        // expected output
        E_N = 0;
        E_V = 0;
        E_Z = 1;
        E_ALUout = 8'd0;

        // input 
        Ain = 8'd53;
        Bin = 8'd53;
        ALUop = 3'b101;
        #10;

        $display("Expected Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, E_ALUout, E_ALUout, E_Z, E_N, E_V);

        $display("Actual Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, Bin, Bin, ALUout, ALUout, Z, N, V);

        pass[20] = (E_Z == Z) & (E_N == N) & (E_V == V) & (E_ALUout == ALUout);
    
        if (pass[20])
            $display("PASS\n");
        else
            $display("FAIL\n");

        $display("## NOT TEST CASES ## \n");

        // regular NOT
        $display("regular NOT\n");

        // expected output
        E_N = 1;
        E_V = 0;
        E_Z = 0;
        E_ALUout = 8'b11110000;

        // input
        Ain = 8'd15;
        ALUop = 3'b110;
        #10;

        $display("Expected Output:");
        $display("Ain = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, E_ALUout, E_ALUout, E_Z, E_N, E_V);

        $display("Actual Output:");
        $display("Ain = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\n", Ain, Ain, ALUout, ALUout, Z, N, V);

        pass[21] = (E_Z == Z) & (E_N == N) & (E_V == V) & (E_ALUout == ALUout);
    
        if (pass[21])
            $display("PASS\n");
        else
            $display("FAIL\n");

        $display("## CARRY OUT TESTS ##");

        // carry out ADD

        $display("carry out ADD\n");

        // expected output
        E_N = 0;
        E_V = 0;
        E_Z = 1;
        E_C = 1;
        E_ALUout = 8'b00000000; 

        // input
        Ain = 8'd255;
        Bin = 8'd1; 
        ALUop = 3'b000; 
        #10;

        $display("Expected Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\nC = %0b\n", Ain, Ain, Bin, Bin, E_ALUout, E_ALUout, E_Z, E_N, E_V, E_C);

        $display("Actual Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\nC = %0b\n", Ain, Ain, Bin, Bin, ALUout, ALUout, Z, N, V, C);

        pass[22] = (E_Z == Z) & (E_N == N) & (E_V == V) & (E_C == C) & (E_ALUout == ALUout);
    
        if (pass[22])
            $display("PASS\n");
        else
            $display("FAIL\n");

        // carry out, signed overflow ADD

        $display("carry out, signed overflow ADD\n");

        // expected output
        E_N = 0;
        E_V = 1;
        E_Z = 1;
        E_C = 1;
        E_ALUout = 8'b00000000; 

        // input
        Ain = 8'd128; 
        Bin = 8'd128; 
        ALUop = 3'b000; 
        #10;

        $display("Expected Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\nC = %0b\n", Ain, Ain, Bin, Bin, E_ALUout, E_ALUout, E_Z, E_N, E_V, E_C);

        $display("Actual Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\nC = %0b\n", Ain, Ain, Bin, Bin, ALUout, ALUout, Z, N, V, C);

        pass[23] = (E_Z == Z) & (E_N == N) & (E_V == V) & (E_C == C) & (E_ALUout == ALUout);
    
        if (pass[23])
            $display("PASS\n");
        else
            $display("FAIL\n");

        // no borrow/carry out SUB

        $display("no carry out SUB (no borrow)\n");

        // expected output
        E_N = 0;
        E_V = 0;
        E_Z = 0;
        E_C = 0;
        E_ALUout = 8'b00001111; 

        // input
        Ain = 8'd45;
        Bin = 8'd30;
        ALUop = 3'b001; 
        #10;

        $display("Expected Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\nC = %0b\n", Ain, Ain, Bin, Bin, E_ALUout, E_ALUout, E_Z, E_N, E_V, E_C);

        $display("Actual Output:");
        $display("ALUresult = %b\n", a.ALUresult);
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\nC = %0b\n", Ain, Ain, Bin, Bin, ALUout, ALUout, Z, N, V, C);

        pass[24] = (E_Z == Z) & (E_N == N) & (E_V == V) & (E_C == C) & (E_ALUout == ALUout);
    
        if (pass[24])
            $display("PASS\n");
        else
            $display("FAIL\n");

        // borrow/carry out SUB

        $display("carry out SUB (borrow)\n");

        // expected output
        E_N = 1;
        E_V = 0;
        E_Z = 0;
        E_C = 1;
        E_ALUout = 8'b11110001; 

        // input
        Ain = 8'd30;
        Bin = 8'd45;
        ALUop = 3'b001; 
        #10;

        $display("Expected Output:");
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\nC = %0b\n", Ain, Ain, Bin, Bin, E_ALUout, E_ALUout, E_Z, E_N, E_V, E_C);

        $display("Actual Output:");
        $display("ALUresult = %b\n", a.ALUresult);
        $display("Ain = %b (unsigned %0d)\nBin = %b (unsigned %0d)\nALUout = %b (unsigned %0d)\nZ = %b\nN = %b\nV = %0b\nC = %0b\n", Ain, Ain, Bin, Bin, ALUout, ALUout, Z, N, V, C);

        pass[25] = (E_Z == Z) & (E_N == N) & (E_V == V) & (E_C == C) & (E_ALUout == ALUout);
    
        if (pass[25])
            $display("PASS\n");
        else
            $display("FAIL\n");

        // summarize results

        $display("## TEST SUMMARY ##");
        
        pass_count = 5'd0;

        for (i = 0; i < TEST_TOTAL; i = i + 1) 
            begin
                new_pass = pass >> i;
                if (new_pass & pass_mask)
                    begin
                        pass_count = pass_count + 1;
                        $display("TEST %0d: PASS", i);
                    end
                else 
                    begin
                    $display("TEST %0d: FAIL", i);
                    pass_count = pass_count;
                    end
            end
        
        $display("%0d of %0d cases PASSED.", pass_count, TEST_TOTAL);

        // stop the simulation
        $finish;
    end
    
endmodule 
