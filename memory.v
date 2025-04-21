module memory(
  input clk,
  input [31:0] address,
  input [31:0] data_in,
  output [31:0] data_out,
  input we
);

reg [31:0] mem[0:1024]; // 16KB de memória
integer i;

assign data_out = mem[address[12:2]]; // was 13:2, raising a warning

always @(posedge clk) begin
  if (we) begin
    mem[address[12:2]] = data_in; // was 13:2, raising a warning
  end
end


initial begin
  for (i = 0; i < 1024; i = i + 1) begin
    mem[i] = 32'h00000000;
  end
  $readmemh("memory.mem", mem);
end

endmodule
