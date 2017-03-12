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

    wire [15:0] data_pins_in;
    wire [15:0] data_pins_out;
    wire data_pins_out_en;
    
    SB_IO #(
        .PIN_TYPE(6'b 1010_01),
    ) sram_data_pins [15:0] (
        .PACKAGE_PIN(DAT),
        .OUTPUT_ENABLE(data_pins_out_en),
        .D_OUT_0(data_pins_out),
        .D_IN_0(data_pins_in),
    );

    reg slow_clk;
    reg [17:0] address;
    wire [15:0] data_read;
    reg [15:0] data_write;
    reg read;
    reg write;
    reg reset;
    reg ready;
    reg [15:0] counter;
    reg read_write;

    initial begin
        read_write <= 0;
        read <= 0;
        write <= 0;
        reset <= 0;
        address <= 0;
        data_write <= 16'hAAAA;
    end

    wire [15:0] data_pins_in;
    wire [15:0] data_pins_out;
    wire set_data_pins;

    assign PMOD = data_read[14:11];
    
    sram sram_test(.clk(clk), .address(address), .data_read(data_read), .data_write(data_write), .write(write), .read(read), .reset(reset), .ready(ready), 
        .data_pins_in(data_pins_in), 
        .data_pins_out(data_pins_out), 
        .data_pins_out_en(data_pins_out_en),
        .address_pins(ADR), 
        .OE(RAMOE), .WE(RAMWE), .CS(RAMCS));

    clk_divn #(.WIDTH(32), .N(1000)) 
        clockdiv_slow(.clk(clk), .clk_out(slow_clk));

    always @(posedge slow_clk) begin
        address <= counter;
        if(read_write) begin
            if(ready) begin
                counter <= counter + 1;
                read <= 1;
            end else
                read <= 0;
        end else begin
            if(ready) begin
                data_write <= counter;
                counter <= counter + 1;
                write <= 1;
            end else
           write <= 0;
        end
        // flip each cycle of the counter
        if(counter == 0)
            read_write <= read_write ? 0 : 1;
    end
endmodule
