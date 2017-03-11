PROJ = sram
PIN_DEF = blackice.pcf
DEVICE = 8k

SRC = top.v sram.v clockdiv.v

all: $(PROJ).rpt $(PROJ).bin

%.blif: %.v $(SRC)
	yosys -p "synth_ice40 -top top -blif $@" $^

%.asc: $(PIN_DEF) %.blif
	arachne-pnr -d $(subst hx,,$(subst lp,,$(DEVICE))) --package tq144:4k -o $@ -p $^

%.bin: %.asc
	icepack $< $@

%.rpt: %.asc
	icetime -d hx8k -mtr $@ $<

debug-sram:
	iverilog -o sram sram.v sram_tb.v
	vvp sram -fst
	gtkwave test.vcd gtk-sram.gtkw

prog:
	bash -c "cat sram.bin > /dev/ttyUSB0"

clean:
	rm -f $(PROJ).blif $(PROJ).asc $(PROJ).rpt $(PROJ).bin

.SECONDARY:
.PHONY: all prog clean
