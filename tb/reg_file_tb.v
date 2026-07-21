`timescale 1ns/1ps

module reg_file_tb;
    // declare DUT inputs as reg
    reg [1:0] ra, rb, rw;
    reg [7:0] dataIn;
    reg RFW;
    reg clk;
    reg reset;

    // declare DUT outputs as wire
    wire [7:0] dataA, dataB;

    // instantiate the DUT (register file)
    reg_file RF(.ra(ra), 
                .rb(rb),
                .rw(rw), 
                .RFW(RFW), 
                .dataIn(dataIn), 
                .dataA(dataA), 
                .dataB(dataB), 
                .clk(clk),
                .reset(reset));

    // defining task for register read
    task reg_read;
        input [4:0] test_number;
        input [1:0] read_a, read_b;
        input [7:0] expected_a, expected_b;

        begin
        // driving DUT inputs
        $display("Test %0d", test_number);
        ra = read_a;
        rb = read_b;

        // wait a while for combinational logic to settle
        // to prevent race conditions
        // nothing to do with hold/settle time bc it's all combinational
        #5;

        $display("Expected Output:");
        $display("  dataA: %h\n  dataB: %h", expected_a, expected_b);
        $display("Actual Output:");
        $display("  dataA: %h\n  dataB: %h\n", dataA, dataB);

        if (expected_a == dataA && expected_b == dataB)
            $display("PASS\n");
        else 
            $display("FAIL\n");
        end
    endtask

    // defining task for register write
    task reg_write;
        input [4:0] test_number;
        input W;
        input [1:0] write_reg;
        input [7:0] dataW;

        begin
        // driving DUT inputs
        $display("Test %0d", test_number);

        // driving DUT inputs on negative clock edge so they are 
        // stable before DUT samples on positive clock edge
        @ (negedge clk)
        begin
            RFW <= W;
            rw <= write_reg;
            dataIn <= dataW;
        end

        // using non-blocking assignment so DUT samples previous
        // value on positive clock edge before deasserting 
        // full task completes in 1 clock cycle
        @ (posedge clk)
            RFW <= 1'b0;

        if (!W)
            $display("Register %d will not update.\n", write_reg);
        else 
            $display("Write %h to register %d\n", dataW, write_reg);
        end
    endtask

    // generate 100MHz clock
    // the clock should be in a separate initial block; 
    // all initial blocks start running once at the start of simulation.
    // the forever block should be its own block so it doesn't block 
    // the rest of the testbench from running
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
        // create .vcd file for waveforms
        $dumpfile("reg_file_tb.vcd");

        $dumpvars(0, reg_file_tb);

        // wait before the first clock edge to prevent event ordering ambiguity
        // (catch the first posedge clk cleanly/entirely)
        #3;

        // test a write first to prevent reading garbage values on first read test
        // RFW = 1, r0 = 0f
        reg_write(5'd0, 1'b1, 2'b00, 8'b00001111);

        // RFW = 1, r1 = aa
        reg_write(5'd1, 1'b1, 2'b01, 8'b10101010);

        // Test 2: r0 = 0f, r1 = aa
        reg_read(5'd2, 2'b00, 2'b01, 8'b00001111, 8'b10101010);

        // RFW = 0, r0 = f0
        reg_write(5'd3, 1'b0, 2'b00, 8'b11110000);

        // RFW = 1, r2 = 01
        reg_write(5'd4, 1'b1, 2'b10, 8'b00000001);

        // Test 5: r0 = 0f, r2 = 01
        reg_read(5'd5, 2'b00, 2'b10, 8'b00001111, 8'b00000001);

        // RFW = 1, r3 = 08
        reg_write(5'd6, 1'b1, 2'b11, 8'b00001000);

        // RFW = 0, r3 = 80
        reg_write(5'd7, 1'b0, 2'b11, 8'b10000000);

        // Test 8: r3 = 08, r1 = aa
        reg_read(5'd8, 2'b11, 2'b01, 8'b00001000, 8'b10101010);

        // Test 9: r1 = aa, r1 = aa
        reg_read(5'd9, 2'b01, 2'b01, 8'b10101010, 8'b10101010);

        // RFW = 1, r3 = ff
        reg_write(5'd10, 1'b1, 2'b11, 8'b11111111);

        // Test 10: r2 = 01, r3 = ff
        reg_read(5'd11, 2'b10, 2'b11, 8'b00000001, 8'b11111111);

        // Test asynchronous reset
        #2;
        reset = 1;

        reg_read(5'd12, 2'b00, 2'b01, 8'd0, 8'd0);
        reg_read(5'd13, 2'b10, 2'b11, 8'd0, 8'd0);

        $finish;
    end

endmodule

/* BLOCKING ON SAME CLOCK EDGE AS DUT SAMPLING TIME--> RACE CONDITION
 ** CAN PREVENT IF USE #1 BEFORE DEASSERTING RFW

    // defining task for register write
    task reg_write;
        input [4:0] test_number;
        input W;
        input [1:0] write_reg;
        input [7:0] dataW;

        begin
        // driving DUT inputs
        //$display("Test number: %0d", test_number);
        RFW = W;
        rw = write_reg;
        dataIn = dataW;

        @ (posedge clk)
        begin
            #1;
            RFW = 1'b0;
        end
        end
    endtask

*/
/* 2 CLOCK-CYCLE METHOD - UNBLOCKING

    // defining task for register write
    task reg_write;
        input [4:0] test_number;
        input W;
        input [1:0] write_reg;
        input [7:0] dataW;

        begin
        // driving DUT inputs
        $display("Test %0d", test_number);

        // driving DUT inputs using non-blocking assignment
        // to ensure DUT flipflops use old values first
        // (avoids race condition with DUT)
        @ (posedge clk)
        begin
            RFW <= W;
            rw <= write_reg;
            dataIn <= dataW;
        end

        // wait for next clock edge; give DUT full clock cycle to 
        // sample current RFW before updating to 1'b0 by using 
        // non-blocking and prevent racing
        @ (posedge clk)
            RFW <= 1'b0;

        if (!RFW)
            $display("Register %d will not update.\n", rw);
        else 
            $display("Write %h to register %d\n", dataIn, rw);
        end
    endtask

*/
