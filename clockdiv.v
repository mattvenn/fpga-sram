module clk_divn #(
parameter WIDTH = 3,
parameter N = 5)
 
(clk,reset, clk_out);
 
input clk;
input reset;
output clk_out;
 
reg [WIDTH-1:0] pos_count, neg_count;
wire [WIDTH-1:0] r_nxt;
 
 always @(posedge clk)
 if (reset)
 pos_count <=0;
 else if (pos_count ==N-1) pos_count <= 0;
 else pos_count<= pos_count +1;
 
 always @(negedge clk)
 if (reset)
 neg_count <=0;
 else  if (neg_count ==N-1) neg_count <= 0;
 else neg_count<= neg_count +1; 
 
assign clk_out = ((pos_count > (N>>1)) | (neg_count > (N>>1))); 
endmodule
