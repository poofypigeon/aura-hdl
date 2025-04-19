GHDL=ghdl
GHDLFLAGS= --std=08

# Default target
all: psr_pack_tb

# Elaboration target
psr_pack_tb: util_pack.o psr_pack.o psr_pack_tb.o
	$(GHDL) -e $(GHDLFLAGS) $@

util_pack.o: ../util_pack.vhd
	$(GHDL) -a $(GHDLFLAGS) $<
psr_pack.o: ../psr_pack.vhd
	$(GHDL) -a $(GHDLFLAGS) $<
psr_pack_tb.o: tb/psr_pack_tb.vhd
	$(GHDL) -a $(GHDLFLAGS) $<
