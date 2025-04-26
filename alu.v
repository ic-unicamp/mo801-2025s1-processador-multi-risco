module alu(
  input [2:0] alu_op,
  input sign_op,
  input [31:0] srcA,
  input [31:0] srcB,
  output reg [31:0] result,
  output wire zero
);

localparam [2:0] ADD  = 3'b000,
                 SLL  = 3'b001,
                 SLT  = 3'b010,
                 SLTU = 3'b011,
                 XOR  = 3'b100,
                 SRL  = 3'b101,
                 OR   = 3'b110,
                 AND  = 3'b111;

assign zero = ~( |result );

always @(*) begin
    case (alu_op)
        ADD: begin
          if (sign_op == 1'b0)
            result = srcA - srcB ;
          else
            result = srcA + srcB ;
        end
        SRL: begin
          if (sign_op == 1'b1)
            result = $signed(srcA) >>> srcB [4:0];
          else
            result = srcA >> srcB [4:0];
        end
        AND:
          result = srcA & srcB ;
        OR:
          result = srcA | srcB ;
        XOR:
          result = srcA ^ srcB ;
        SLL:
          result = srcA << srcB [4:0];
        SLT:
          result = ($signed(srcA) < $signed(srcB)) ? 32'b1 : 32'b0;
        SLTU:
          result = (srcA < srcB) ? 32'b1 : 32'b0;
        default:
          result = 32'b0;
    endcase
end

endmodule;
