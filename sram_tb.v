module test;

  reg clk = 0;
  reg reset = 0;
  reg write = 0;
  reg read = 0;
  wire ready;
  reg [17:0] address;
  wire [15:0] data_read;
  reg [15:0] data_write;
  output [15:0] data_pins_out;
  input [15:0] data_pins_in;

  wire CS;
  wire OE;
  wire WE;

  reg set_data = 0;
  assign data_pins_in = set_data ? 16'h0A0A : 16'hzz;
  initial begin
     $dumpfile("test.vcd");
     $dumpvars(0,test);
     $dumpon;
     # 1 reset = 1;
     # 2 reset = 0;
     // write
     # 1 address = 17'h0;
     # 1 data_write = 16'hAAAA;
     # 2 write = 1;
     # 2 write = 0;
     wait(ready == 1);
     // read
     # 1 set_data <= 1;
     # 2 read = 1;
     # 2 read = 0;
     # 20
     $finish;
  end

  sram sram_test(.clk(clk), .address(address), .data_read(data_read), .data_write(data_write), .write(write), .read(read), .reset(reset), .ready(ready), .data_pins_out(data_pins_out), .data_pins_in(data_pins_in), .OE(OE), .CS(CS), .WE(WE));

  always #1 clk = !clk;

endmodule // test
