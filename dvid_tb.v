module test;

  reg clk = 0;
  reg clkx5 = 0;
  wire hsync;
  wire vsync;
  wire blank;
  wire [2:0] red;
  wire [2:0] green;
  wire [2:0] blue;

  /* Make a reset that pulses once. */
  initial begin
     $dumpfile("test.vcd");
     $dumpvars(0, 
        dvid_test.ctls[0],
        dvid_test.symbols[0],
        dvid_test.symbols[1],
        dvid_test.symbols[2],
        dvid_test.symbols[3],
        dvid_test.high_speed_sr[0],
        dvid_test.high_speed_sr[1],
        dvid_test.high_speed_sr[2],
        dvid_test.high_speed_sr[3],
        dvid_test.output_bits[0],
        dvid_test.output_bits[1],
        dvid_test.output_bits[2],
        dvid_test.output_bits[3],
        test);
//     $dumpoff;
//    # 2000000;
     $dumpon;
     # 20000;
     $finish;
  end

  vga vga_test(.clk(clk), .hsync(hsync), .vsync(vsync), .blank(blank), .red(red), .green(green), .blue(blue));

  dvid dvid_test(.clk(clk), .clkx5(clkx5), .hsync(hsync), .vsync(vsync), .blank(blank), .red(red), .green(green), .blue(blue));

  /* Make a regular pulsing clock. */
  always #1 clkx5 = !clkx5;
  always #5 clk = !clk;

endmodule // test

