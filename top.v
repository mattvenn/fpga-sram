`default_nettype none

module top (
	input  clk,
    output [3:0] PMOD,
    output [17:0] ADR,
    inout [15:0] DAT,
    output RAMOE,
    output RAMWE,
    output RAMCS
);

    reg slow_clk;
    reg [17:0] address;
    wire [15:0] data_read;
    reg [15:0] data_write;
    reg read;
    reg write;
    reg reset;
    reg ready;
    reg [4:0] counter;

    initial begin
        read <= 0;
        write <= 0;
        reset <= 0;
        address <= 0;
        data_write <= 16'hAAAA;
    end

    wire [15:0] data_pins_in;
    wire [15:0] data_pins_out;
    wire set_data_pins;
    SB_IO #(
        .PIN_TYPE(6'b 1010_01),
        //.PULLUP(1'b 0)
    ) sram_data_pins [15:0] (
 //       .PACKAGE_PIN( {DAT[0], DAT[1], DAT[2], DAT[3], DAT[4], DAT[5], DAT[6], DAT[7], DAT[8], DAT[9], DAT[10], DAT[11], DAT[12], DAT[13], DAT[14], DAT[15]} ),
        .PACKAGE_PIN( DAT ),
        .OUTPUT_ENABLE(set_data_pins),
        .D_OUT_0(data_pins_out),
        .D_IN_0(data_pins_in),
//        .INPUT_CLK(clk),
//        .OUTPUT_CLK(clk)
    );

    assign PMOD = data_read;
    
    sram sram_test(.clk(clk), .address(address), .data_read(data_read), .data_write(data_write), .write(write), .read(read), .reset(reset), .ready(ready), 
        .data_pins_in(data_pins_in), 
        .data_pins_out(data_pins_out),
        .set_data_pins(set_data_pins),
      .address_pins(ADR), 
        .OE(RAMOE), .WE(RAMWE), .CS(RAMCS));

    clk_divn #(.WIDTH(32), .N(12000000)) 
        clockdiv_slow(.clk(clk), .clk_out(slow_clk));

    always @(posedge slow_clk) begin
        if(counter == 1) begin
           write <= 1; 
        end
        if(counter == 2) begin
           write <= 0;
        end
        if(counter == 3) begin
           read <= 1;
        end
        if(counter == 4) begin
           read <= 0;
        end
        counter <= counter + 1;
    end

endmodule
