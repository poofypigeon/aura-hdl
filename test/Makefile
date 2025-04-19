include psr_pack_tb.mk
include barrel_shifter_tb.mk

.PHONY: test clean

test: psr_pack_tb barrel_shifter_tb
	$(GHDL) -r psr_pack_tb $(GHDLRUNFLAGS)
	$(GHDL) -r barrel_shifter_tb $(GHDLRUNFLAGS)

clean:
	rm -f psr_pack_tb
	rm -f barrel_shifter_tb
	rm -f *.o
	rm -f *.cf

