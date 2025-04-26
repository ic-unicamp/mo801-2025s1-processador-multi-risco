module core(
  input clk,
  input resetn,
  output reg [31:0] address,
  output reg [31:0] data_out,
  input [31:0] data_in,
  output reg we
);

wire [31:0] mem_read;
reg [31:0] mem_write;
wire mem_read_enable;
wire mem_write_enable;

wire [31:0]registerData1;
wire [31:0]registerData2;

reg [31:0] aluSrcA;
reg [31:0] aluSrcB;
wire aluSelA;
wire aluSelB;
wire [31:0] alu_result;
wire zero_flag;

reg [31:0] program_counter;
reg [31:0] instruction;
wire pc_write;
reg take_jump;
wire take_jump_next;

wire [31:0] immediate;
wire [2:0] state;
wire write_back;
wire load;

//assign write_back = (& state);

wire [6:0] opcode;
wire [4:0] rd;
wire [2:0] funct3;
wire [4:0] rs1;
wire [4:0] rs2;
wire [6:0] funct7;

assign {funct7,rs2,rs1,funct3,rd,opcode} = instruction;

initial begin
  address = 32'h00000000;
  program_counter = 32'h00000000;
end

localparam [2:0] IF  = 3'd0, // Instruction Fetch
                 ID  = 3'd1, // Instruction Decoding
                 EX  = 3'd2, // Execution
                 ME  = 3'd3, // Memory Exchange
                 WB  = 3'd4; // Write Back

always @(posedge clk or negedge resetn) begin
  if (resetn == 1'b0) begin
    program_counter = 32'h00000000;
    take_jump = 1'b0;
    we = 1'b0;
  end
  else begin
    if (state == IF) begin
      instruction = mem_read;
    end
    if (state == EX) begin
      take_jump = take_jump_next;
    end
    if (state == ME) begin
      we = 1;
      data_out = mem_read;
    end
    if (state == WB) begin
      $display("%h", alu_result);
      if (pc_write)
        program_counter = alu_result;
    end
  end
  address = alu_result;
end

always@(*) begin
  if(aluSelA == 0)
    aluSrcA = registerData1;
  else
    aluSrcA = program_counter;

  if(aluSelB == 0)
    aluSrcB = registerData2;
  else if(take_jump)
    aluSrcB = immediate;
  else
    aluSrcB = 32'd4;
end

control_unit Control_FSM(
  .clk(clk),
  .resetn(resetn),
  .opcode(opcode),
  .funct3(funct3),
  .zero_flag(zero_flag),
  .sign_flag(funct7[5]),
  .state(state),
  .pc_write(pc_write),
  .reg_write_enable(write_back),
  .alu_sel_a(aluSelA),
  .alu_sel_b(aluSelB),
  .mem_read_enable(mem_read_enable),
  .mem_write_enable(mem_write_enable),
  .mem_to_reg(load),
  .take_jump_next(take_jump_next)
);

alu ArithmeticLogicalUnit(
  .srcA(aluSrcA),
  .srcB(aluSrcB),
  .alu_op((state == IF) ? 3'b000 : funct3),
  .sign_op(funct7[5]), // Indicates subtraction or SRA
  .result(alu_result),
  .zero(zero_flag)
);

registers register_bank(
  .clk(clk),
  .write_enable(write_back),
  .rs2(rs2),
  .rs1(rs1),
  .rd(rd),
  .data_in(alu_result),
  .registerData1(registerData1),
  .registerData2(registerData2)
);

memory RandomAccessMemory(
  .clk(clk),
  .address(address),
  .data_in(mem_write),
  .data_out(mem_read),
  .we(we)
);

immediate_gen Immediate_Generation(
  .instruction(instruction),
  .immediate(immediate)
);

endmodule
