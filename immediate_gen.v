module immediate_gen(
  input [31:0] instruction,
  output reg [31:0] immediate
);

wire [6:0] opcode;
wire [2:0] func3;
assign opcode = {instruction[6:0]};
assign func3 = {instruction[14:12]};

// Jump format
localparam JAL      = 7'b1101111;

// Upper format
localparam LUI      = 7'b0110111;
localparam AUIPC    = 7'b0010111;

// Immediate format
localparam LOAD     = 7'b0000011;
localparam IMMEDIATE      = 7'b0010011;
localparam JALR     = 7'b1100111;
localparam SYSCALL   = 7'b1110011;

// Branch format
localparam BRANCH   = 7'b1100011;

// Store format
localparam STORE    = 7'b0100011;

// Register format
// localparam REGISTER = 7'b0110011;

always @(instruction) begin
  case(opcode)
    // Jump format
    JAL: begin
      immediate <= {{12{instruction[31]}},
                    instruction[19:12], instruction[20], instruction[30:21], 1'b0};
    end

    // Upper format
    LUI, AUIPC: begin
      immediate <= {instruction[31:12], 12'h000};
    end

    IMMEDIATE: begin // I type instruction
        case (func3)
            3'b001:
              immediate <= {{27{instruction[24]}}, instruction[24:20]};
            3'b011:
              immediate <= {20'h00000, instruction[31:20]};
            3'b101:
              immediate <= {{27'h0000000}, instruction[24:20]};
            default:
              immediate <= {{20{instruction[31]}}, instruction[31:20]};
        endcase
    end
    SYSCALL: // I type instruction  CSR
        immediate <= {20'h00000, instruction[31:20]};
    // Immediate format
    LOAD, JALR: begin
      immediate <= {{20{instruction[31]}}, instruction[31:20]};
    end

    BRANCH: begin
    // Branch format
      immediate <= {{20{instruction[31]}},
                    instruction[7], instruction[30:25], instruction[11:8], 1'b0};
    end

    STORE: begin
    // Store format
      immediate <= {{20{instruction[31]}},
                    instruction[31:25], instruction[11:7]};
    end

    // Formats with no immediates
    // REGISTER or otherwise
    default: begin
      immediate <= 32'h00000000;
    end
  endcase

end

endmodule
