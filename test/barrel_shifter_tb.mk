GHDL=ghdl
GHDLFLAGS= --std=08

# Default target
all: barrel_shifter_tb

# Elaboration target
barrel_shifter_tb: barrel_shifter.o barrel_shifter_tb.o
	$(GHDL) -e $(GHDLFLAGS) $@

barrel_shifter.o: ../barrel_shifter.vhd
	$(GHDL) -a $(GHDLFLAGS) $<
barrel_shifter_tb.o: tb/barrel_shifter_tb.vhd
	$(GHDL) -a $(GHDLFLAGS) $<
