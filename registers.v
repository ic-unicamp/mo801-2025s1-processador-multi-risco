module registers(
  input clk,
  input write_enable,
  input [4:0] rs2,
  input [4:0] rs1,
  input [4:0] rd,
  input [31:0] data_in,
  output [31:0] registerData1,
  output [31:0] registerData2
);

reg [31:0] registers [31:0]; // Register Memory

initial begin
  registers[0] <= 32'b00000000; // x0 is always 0
end

assign registerData1 = registers[rs1];
assign registerData2 = registers[rs2];

always @(posedge clk) begin
  if (write_enable && rd != 0) begin
    registers[rd] <= data_in;
  end
end

endmodule
