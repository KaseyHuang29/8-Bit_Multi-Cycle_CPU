module alu(ALUop, Ain, Bin, shift2bits, Z, N, V, C, ALUout, flagEn);
    input [2:0] ALUop;
    input [7:0] Ain, Bin;
    input [1:0] shift2bits;
    
    input flagEn;
    output reg Z, N, V, C;
    output [7:0] ALUout;
    reg [8:0] ALUresult;
    assign ALUout = ALUresult[7:0];

    parameter ADD = 3'b000, SUB = 3'b001, SHIFT = 3'b010, AND = 3'b011, OR = 3'b100, XOR = 3'b101, NOT = 3'b110;

    wire signed [7:0] AinSigned;
    wire [2:0] BinShift;

    assign AinSigned = Ain; 
    assign BinShift = Bin[2:0];

    always @ (*) 
    begin
        // give default values to avoid latches
        ALUresult = 0;

        case(ALUop)
            ADD: ALUresult = Ain + Bin;

            SUB: ALUresult = Ain - Bin;

            // also works for BGTU:
            //SUB: ALUresult = {1'b0, Ain} + {1'b0, ~Bin} + 9'd1; 
            // concatenate each input into a 9'bit result to match 
            // result bit width and reserve 9th bit as carryout
            // C = 1 "positive result" --> no borrow
            // C = 0 "negative result" --> borrow

            SHIFT:
            begin
                if (shift2bits[0])
                    ALUresult = Ain << BinShift;
                else 
                begin
                    if (shift2bits[1]) ALUresult = Ain >> BinShift;
                    else ALUresult = AinSigned >>> BinShift;
                end
            end

            AND:
                ALUresult = Ain & Bin;
            OR:
                ALUresult = Ain | Bin;
            XOR: 
                ALUresult = Ain ^ Bin;
            NOT:
                ALUresult = ~Ain;
            default:
            begin
                ALUresult = 0;
            end
        endcase
    end
       
    always @ (*)
    begin
        if (flagEn)
            begin
                Z = (ALUout == 0);
                N = ALUout[7];
                C = ALUresult[8];
                if (ALUop == 3'b000)
                    V = ((ALUout[7] != Ain[7]) && (Ain[7] == Bin[7]));
                else if (ALUop == 3'b001)
                    V = ((ALUout[7] != Ain[7]) && (Ain[7] != Bin[7]));
                else
                    V = 0;
            end
        else 
            begin
                Z = 0;
                N = 0;
                V = 0;
                C = 0;
            end
    end

endmodule
