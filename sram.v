`default_nettype none
module sram (
    input wire reset,
    // 50ns max for data read/write. at 12MHz, each clock cycle is 62.5 ns, so write in 1 cycle
	input wire clk,
    input wire write,
    input wire read,
    input wire [15:0] data_write,       // the data to write
    output wire [15:0] data_read,       // the data that's been read
    input wire [17:0] address,          // address to write to
    output wire ready,                  // high when ready for next operation

    // SRAM pins
    output wire [17:0] address_pins,    // address pins of the SRAM
    inout  [15:0] data_pins,
    output wire OE,                     // output enable - low to enable
    output wire WE,                     // write enable - low to enable
    output wire CS                      // chip select - low to enable
);

    wire [15:0] data_pins_out;
    wire [15:0] data_pins_in;

    SB_IO #(
        .PIN_TYPE(6'b 1010_01),
        .PULLUP(1'b 0)
    ) tri_state_data_pins [15:0] (
        .PACKAGE_PIN( data_pins ),
        .OUTPUT_ENABLE(!tri_data_pins),
        .D_OUT_0(data_pins_out),
        .D_IN_0(data_pins_in)
    );

    localparam STATE_IDLE = 0;
    localparam STATE_WRITE = 1;
    localparam STATE_READ_SETUP = 2;
    localparam STATE_READ = 3;

    reg output_enable;
    reg write_enable;
    reg chip_select;

    reg [4:0] state;
    reg [15:0] data_read_reg;
    reg [15:0] data_write_reg;
    reg tri_data_pins;

    assign address_pins = address;
    assign data_pins_out = data_write_reg;
    assign data_read = data_read_reg;

    assign ready = (!reset && state == STATE_IDLE) ? 1 : 0; 

	always@(posedge clk) begin
        if( reset == 1 ) begin
            state <= STATE_IDLE;
            output_enable <= 1;
            chip_select <= 1;
            write_enable <= 1;
            tri_data_pins <= 1;
        end
        else begin
            case(state)
                STATE_IDLE: begin
                    output_enable <= 1;
                    chip_select <= 1;
                    write_enable <= 1;
                    tri_data_pins <= 1;
                    if(write) state <= STATE_WRITE;
                    else if(read) state <= STATE_READ_SETUP;
                end
                STATE_WRITE: begin
                    write_enable <= 0;
                    chip_select <= 0;
                    data_write_reg <= data_write;
                    tri_data_pins <= 0;
                    if(!write) state <= STATE_IDLE;
                end
                STATE_READ_SETUP: begin
                    output_enable <= 0;
                    chip_select <= 0;
                    state <= STATE_READ;
                end
                STATE_READ: begin
                    data_read_reg = data_pins_in;
                    if(!read) state <= STATE_IDLE;
                end
            endcase
        end
    end


endmodule
