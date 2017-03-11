module test;

  reg clk = 0;
  reg reset = 0;
  reg write = 0;
  reg read = 0;
  wire ready;
  reg [17:0] address;
  wire [15:0] data_read;
  reg [15:0] data_write;

  initial begin
     $dumpfile("test.vcd");
     $dumpvars(0,test);
     $dumpon;
     # 1 reset = 1;
     # 2 reset = 0;
     // write
     # 4 address = 17'h0;
     # 4 data_write = 16'hAAAA;
     # 5 write = 1;
     # 6 write = 0;
     // read
     # 10 read = 1;
     # 11 read = 0;
     # 20
     $finish;
  end

  sram sram_test(.clk(clk), .address(address), .data_read(data_read), .data_write(data_write), .write(write), .read(read), .reset(reset), .ready(ready));

  always #1 clk = !clk;

endmodule // test
