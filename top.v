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

    assign PMOD = data_read;
    
    sram sram_test(.clk(clk), .address(address), .data_read(data_read), .data_write(data_write), .write(write), .read(read), .reset(reset), .ready(ready), 
        .data_pins(DAT), 
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
