module control_fsm(clk, reset, opcode, N, Z, V, memRI, IRLd, PColdW, RegLd, PCsel, incrSel, PCW, RFW, Bsel, 
                   ALUop, ALUoutLd, flagW, dataSel, MDRLd, memRD, memW);
    input clk, reset, N, V, Z;
    input [3:0] opcode;
    output reg memRI, IRLd, PColdW, RegLd, PCsel, incrSel, PCW, RFW, Bsel, ALUoutLd, flagW, MDRLd, memRD, memW;
    output reg [2:0] ALUop;
    output reg [1:0] dataSel;
    reg [1:0] cycle, nextCycle;

    parameter cycle0 = 2'b00, cycle1 = 2'b01, cycle2 = 2'b10, cycle3 = 2'b11;
    parameter LOAD = 4'd0, STORE = 4'd1, MOV = 4'd2, LDI = 4'd3, ADD = 4'd4, ADDI = 4'd5, 
              SUB = 4'd6, SHIFT = 4'd7, AND = 4'd8, OR  = 4'd9, XOR = 4'd10, NOT = 4'd11, 
              JMP = 4'd12, BNE = 4'd13, BGT = 4'd14;

    always @ (*)
    begin
        PColdW = 0;
        PCW = 0;
        memRD = 0;
        memW = 0;
        memRI = 0;
        MDRLd = 0;
        IRLd = 0;
        RFW = 0;
        RegLd = 0;
        flagW = 0;
        ALUoutLd = 0;
        PColdW = 0;
        PCsel = 0;
        incrSel = 0;
        Bsel = 0;
        ALUop = 3'b000;
        dataSel = 2'b00;
        nextCycle = cycle0;

        case(cycle)
            cycle0:
            begin
                memRI = 1;
                IRLd = 1;
                PColdW = 1;
                nextCycle = cycle1;
            end

            cycle1:
            begin
                RegLd = 1;
                PCsel = 0;
                incrSel = 0;
                PCW = 1;
                nextCycle = cycle2;
            end

            cycle2:
            begin
                nextCycle = cycle3;

                case(opcode)
                    LOAD: 
                    begin
                        memRD = 1;
                        MDRLd = 1;
                        nextCycle = cycle3;
                    end

                    STORE:
                    begin
                        memRD = 1;
                        memW = 1;
                        nextCycle = cycle0;
                    end

                    MOV:
                    begin
                        dataSel = 2'b11;
                        RFW = 1;
                        nextCycle = cycle0;
                    end

                    LDI:
                    begin
                        dataSel = 2'b00;
                        RFW = 1;
                        nextCycle = cycle0;
                    end

                    ADD:
                    begin
                        Bsel = 0;
                        ALUop = 3'b000;
                        flagW = 1;
                        ALUoutLd = 1;
                        nextCycle = cycle3;
                    end

                    ADDI:
                    begin
                        Bsel = 1;
                        ALUop = 3'b000;
                        flagW = 1;
                        ALUoutLd = 1;
                        nextCycle = cycle3;
                    end

                    SUB:
                    begin
                        Bsel = 0;
                        ALUop = 3'b001;
                        flagW = 1;
                        ALUoutLd = 1; 
                        nextCycle = cycle3; 
                    end

                    SHIFT:
                    begin
                        Bsel = 1;
                        ALUop = 3'b010;
                        flagW = 1;
                        ALUoutLd = 1;
                        nextCycle = cycle3;
                    end

                    AND:
                    begin
                        Bsel = 0;
                        ALUop = 3'b011;
                        flagW = 1;
                        ALUoutLd = 1;
                        nextCycle = cycle3;
                    end

                    OR:
                    begin
                        Bsel = 0;
                        ALUop = 3'b100;
                        flagW = 1;
                        ALUoutLd = 1;
                        nextCycle = cycle3;
                    end

                    XOR:
                    begin
                        Bsel = 0;
                        ALUop = 3'b101;
                        flagW = 1;
                        ALUoutLd = 1;
                        nextCycle = cycle3;
                    end

                    NOT:
                    begin
                        Bsel = 0;
                        ALUop = 3'b110;
                        flagW = 1;
                        ALUoutLd = 1;
                        nextCycle = cycle3;
                    end

                    JMP:
                    begin
                        PCsel = 1;
                        incrSel = 1;
                        PCW = 1;
                        nextCycle = cycle0;
                    end

                    BNE:
                    begin
                        Bsel = 0;
                        ALUop = 3'b001;
                        flagW = 1;
                        nextCycle = cycle3;
                    end

                    BGT:
                    begin
                        Bsel = 0;
                        ALUop = 3'b001;
                        flagW = 1;
                        nextCycle = cycle3;
                    end
                    
                    default:
                    begin
                        PColdW = 0;
                        PCW = 0;
                        memRD = 0;
                        memW = 0;
                        memRI = 0;
                        MDRLd = 0;
                        IRLd = 0;
                        RFW = 0;
                        RegLd = 0;
                        flagW = 0;
                        ALUoutLd = 0;
                        nextCycle = cycle3;
                    end
                endcase
                
            end

            cycle3:
            begin
                nextCycle = cycle0;

                case(opcode)
                    LOAD: 
                    begin
                        dataSel = 2'b00;
                        RFW = 1;
                        nextCycle = cycle0;
                    end

                    ADD:
                    begin
                        dataSel = 2'b10;
                        RFW = 1;
                        nextCycle = cycle0;
                    end

                    ADDI:
                    begin
                        dataSel = 2'b10;
                        RFW = 1;
                        nextCycle = cycle0;
                    end

                    SUB:
                    begin
                        dataSel = 2'b10;
                        RFW = 1;
                        nextCycle = cycle0;
                    end

                    SHIFT:
                    begin
                        dataSel = 2'b10;
                        RFW = 1;
                        nextCycle = cycle0;
                    end

                    AND:
                    begin
                        dataSel = 2'b10;
                        RFW = 1;
                        nextCycle = cycle0;
                    end

                    OR:
                    begin
                        dataSel = 2'b10;
                        RFW = 1;
                        nextCycle = cycle0;
                    end

                    XOR:
                    begin
                        dataSel = 2'b10;
                        RFW = 1;
                        nextCycle = cycle0;
                    end

                    NOT:
                    begin
                        dataSel = 2'b10;
                        RFW = 1;
                        nextCycle = cycle0;
                    end

                    JMP:
                    begin
                        PCsel = 1;
                        incrSel = 1;
                        PCW = 1;
                        nextCycle = cycle0;
                    end

                    BNE:
                    begin
                        if (!Z)
                        begin
                            PCsel = 1;
                            incrSel = 1;
                            PCW = 1;
                            nextCycle = cycle0;
                        end
                        else 
                            nextCycle = cycle0;
                    end

                    BGT:
                    begin
                        if (!Z && (N == V))
                        begin
                            PCsel = 1;
                            incrSel = 1;
                            PCW = 1;
                            nextCycle = cycle0;
                        end
                    end
                    
                    default:
                    begin
                        PColdW = 0;
                        PCW = 0;
                        memRD = 0;
                        memW = 0;
                        memRI = 0;
                        MDRLd = 0;
                        IRLd = 0;
                        RFW = 0;
                        RegLd = 0;
                        flagW = 0;
                        ALUoutLd = 0;
                        nextCycle = cycle0;
                    end
                endcase
            end
        endcase
    end

    always @ (posedge clk or posedge reset)
    begin
        if (reset)
            cycle <= cycle0;
        else 
            cycle <= nextCycle;
    end

endmodule