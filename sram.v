`default_nettype none
module sram (
    input wire reset,
    // 50ns max for data read/write. at 12MHz, each clock cycle is 83ns, so write in 1 cycle
	input wire clk,
    input wire write,
    input wire read,
    input wire [15:0] data_write,       // the data to write
    output wire [15:0] data_read,       // the data that's been read
    input wire [17:0] address,          // address to write to
    output wire ready,                  // high when ready for next operation
    output wire data_pins_out_en,       // when to switch between in and out on data pins

    // SRAM pins
    output wire [17:0] address_pins,    // address pins of the SRAM
    input  wire [15:0] data_pins_in,
    output wire [15:0] data_pins_out,
    output wire OE,                     // output enable - low to enable
    output wire WE,                     // write enable - low to enable
    output wire CS                      // chip select - low to enable
);

    localparam STATE_IDLE = 0;
    localparam STATE_WRITE = 1;
    localparam STATE_WRITE_SETUP = 4;
    localparam STATE_READ_SETUP = 2;
    localparam STATE_READ = 3;

    reg output_enable;
    reg write_enable;
    reg chip_select;

    reg [4:0] state;
    reg [15:0] data_read_reg;
    reg [15:0] data_write_reg;

    assign data_pins_out_en = (state == STATE_WRITE) ? 1 : 0; // turn on output pins when writing data
    assign address_pins = address;
    assign data_pins_out = data_write_reg;
    assign data_read = data_read_reg;
    assign OE = output_enable;
    assign WE = write_enable;
    assign CS = chip_select;

    assign ready = (!reset && state == STATE_IDLE) ? 1 : 0; 

    initial begin
        state <= STATE_IDLE;
        output_enable <= 1;
        chip_select <= 1;
        write_enable <= 1;
    end

	always@(posedge clk) begin
        if( reset == 1 ) begin
            state <= STATE_IDLE;
            output_enable <= 1;
            chip_select <= 1;
            write_enable <= 1;
        end
        else begin
            case(state)
                STATE_IDLE: begin
                    output_enable <= 1;
                    chip_select <= 1;
                    write_enable <= 1;
                    if(write) state <= STATE_WRITE_SETUP;
                    else if(read) state <= STATE_READ_SETUP;
                end
                STATE_WRITE_SETUP: begin
                    chip_select <= 0;
                    data_write_reg <= data_write;
                    state <= STATE_WRITE;
                end
                STATE_WRITE: begin
                    write_enable <= 0;
                    state <= STATE_IDLE;
                end
                STATE_READ_SETUP: begin
                    output_enable <= 0;
                    chip_select <= 0;
                    state <= STATE_READ;
                end
                STATE_READ: begin
                    data_read_reg <= data_pins_in;
                    state <= STATE_IDLE;
                end
            endcase
        end
    end


endmodule
