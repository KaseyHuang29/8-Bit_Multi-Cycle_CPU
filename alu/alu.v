module alu(ALUop, Ain, Bin, shift2bits, Z, N, V, ALUout, flagW);
    input [2:0] ALUop;
    input [7:0] Ain, Bin;
    input [1:0] shift2bits;
    input flagW;
    output reg Z, N, V;
    output reg [7:0] ALUout;

    parameter ADD = 3'b000, SUB = 3'b001, SHIFT = 3'b010, AND = 3'b011, OR = 3'b100, XOR = 3'b101, NOT = 3'b110;

    wire signed [7:0] AinSigned;
    wire [2:0] BinShift;

    assign AinSigned = Ain; 
    assign BinShift = Bin[2:0];

    always @ (*) 
    begin
        /*
        ALUout = 0;
        V = 0;
        Z = 0;
        N = 0;

        case(ALUop)
            ADD: ALUout = Ain + Bin;

            SUB: ALUout = Ain - Bin;

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

            OR: ALUout = Ain | Bin;

            XOR: 
                ALUout = Ain ^ Bin;

            NOT:
                ALUout = ~Ain;
            default: ALUout = 8'd0;
        endcase

        if (flagW)
            begin
                Z = (ALUout == 0);
                N = ALUout[7];
                V = ((ALUout[7] != Ain[7]) & (Ain[7] == Bin[7]));
            end
        */



        // give default values to avoid latches
        ALUout = 0;

        case(ALUop)
            ADD: ALUout = Ain + Bin;

            SUB: ALUout = Ain - Bin;

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
            end
        endcase
    end
        // IF HAVE TROUBLE LATER, ADD ELSE STATEMENT MAKING Z,N = 0
    always @ (*)
    begin
            if (flagW)
                begin
                    Z = (ALUout == 0);
                    N = ALUout[7];
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
                end
    end

endmodule
