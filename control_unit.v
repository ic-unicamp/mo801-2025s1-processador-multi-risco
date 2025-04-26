module control_unit (
  input wire clk,
  input wire resetn,
  input wire [6:0] opcode,
  input wire [2:0] funct3,
  input wire zero_flag,
  input wire sign_flag,
  output reg [2:0] state,
  output reg alu_sel_a,
  output reg alu_sel_b,
  output reg pc_write,
  output reg reg_write_enable,
  output reg mem_read_enable,
  output reg mem_write_enable,
  output reg mem_to_reg,
  output reg take_jump_next
);

// FSM state definitions
localparam [2:0] IF  = 3'd0, // Instruction Fetch
                 ID  = 3'd1, // Instruction Decoding
                 EX  = 3'd2, // Execution
                 ME  = 3'd3, // Memory Exchange
                 WB  = 3'd4; // Write Back

// OPCODE definitions
localparam [6:0] LUI      = 7'b0110111,
                 AUIPC    = 7'b0010111,
                 JAL      = 7'b1101111,
                 JALR     = 7'b1100111,
                 BRANCH   = 7'b1100011,
                 LOAD     = 7'b0000011,
                 STORE    = 7'b0100011,
                 TYPE_IMM = 7'b0010011,
                 TYPE_REG = 7'b0110011;

// BRANCH funct3 definitions
localparam [2:0] BEQ  = 3'b000,
                 BNE  = 3'b001,
                 BLT  = 3'b100,
                 BGE  = 3'b101,
                 BLTU = 3'b110,
                 BGEU = 3'b111;

reg [2:0] next_state;
reg zero_next;

always @(posedge clk or negedge resetn) begin
  if (resetn == 0) begin
    state = IF;
  end
  else begin
    state = next_state;
  end
  if (state == EX) begin
    zero_next = zero_flag;
  end
end

always @(*) begin
  case (state)
    IF:  next_state = ID;
    ID:  next_state = EX;

    EX: begin
      case (opcode)
        LOAD, STORE:
          next_state = ME;
        default:
          next_state = WB;
      endcase
    end

    ME: begin
      if (opcode == LOAD)
        next_state = WB;
      else
        next_state = IF;
    end

    //   WB: next_state = IF;
    default: next_state = IF;
  endcase
end

always @(*) begin
  case (opcode)
    JAL,JALR:
      take_jump_next = 1'b1;

    BRANCH:
      case (funct3)
        BEQ:     take_jump_next = zero_next;
        BNE:     take_jump_next = ~zero_next;
        BLT:     take_jump_next = sign_flag;
        BGE:     take_jump_next = ~sign_flag;
        default: take_jump_next = 1'b0;
      endcase

    default: take_jump_next = 1'b0;
  endcase

  pc_write         = (state == IF
                   || take_jump_next);

  reg_write_enable = (state == WB
                   && opcode != STORE
                   && opcode != BRANCH);

  // == 1 for PC as src
  alu_sel_a        = (opcode == JAL
                   || opcode == AUIPC);

  // == 1 for immediate src
  alu_sel_b      = (opcode == TYPE_IMM
                   || opcode == LOAD
                   || opcode == STORE
                   || opcode == AUIPC
                   || take_jump_next); // True when opcode == JAL || opcode == JALR

  mem_read_enable  = (state == ME
                   && opcode == LOAD);

  mem_write_enable = (state == ME
                   && opcode == STORE);

  mem_to_reg       = (opcode == LOAD);
end
endmodule
