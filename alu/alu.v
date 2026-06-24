module alu(ALUop, Ain, Bin, shift2bits, Z, N, V, ALUout);
    input [2:0] ALUop;
    input [7:0] Ain, Bin;
    input [1:0] shift2bits;
    output reg Z, N, V;
    output reg [7:0] ALUout;

    parameter ADD = 3'b000, SUB = 3'b001, SHIFT = 3'b010, AND = 3'b011, OR = 3'b100, XOR = 3'b101, NOT = 3'b110;

    wire signed [7:0] AinSigned;
    wire [2:0] BinShift;

    assign AinSigned = Ain; 
    assign BinShift = Bin[2:0];

    always @ (*) 
    begin
        // give default values to avoid latches
        ALUout = 0;
        Z = 0;
        N = 0;
        V = 0;
        case(ALUop)
            ADD:
            begin
                ALUout = Ain + Bin;
                V = ((ALUout[7] != Ain[7]) & (Ain[7] == Bin[7]));
            end

            SUB:
            begin
                ALUout = Ain - Bin;
                V = ((ALUout[7] != Ain[7]) & (Ain[7] != Bin[7]));
            end

            SHIFT:
            begin
                if (shift2bits[0])
                    ALUout = Ain << BinShift;
                else 
                begin
                    if (shift2bits[1]) ALUout = Ain >> BinShift;
                    else ALUout = AinSigned >>> BinShift;
                end
            end
            
            AND:
                ALUout = Ain & Bin;
            OR:
                ALUout = Ain | Bin;
            XOR: 
                ALUout = Ain ^ Bin;
            NOT:
                ALUout = ~Ain;
            default:
            begin
                ALUout = 0;
                V = 0;
            end
        endcase
        Z = (ALUout == 0);
        N = ALUout[7];
    end
endmodule