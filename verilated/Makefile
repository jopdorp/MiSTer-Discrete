VERILATOR = verilator
VFLAGS = -Wall --trace --cc
TB = tb_resistor_capacitor_high_pass_filter
SV = $(subst tb_,,$(TB))
VFILES = ../$(SV).sv $(TB).cpp
VFLAGS = --trace --cc -Wno-WIDTH -Wno-CASEX -I../ -I../math/
EXE = $(TB)

all: $(EXE)

$(EXE): $(VFILES)
	$(VERILATOR) $(VFLAGS) $(VFILES)
	make -C obj_dir -f V$(SV).mk
	g++ -I/usr/share/verilator/include -Iobj_dir/ /usr/share/verilator/include/verilated.cpp /usr/share/verilator/include/verilated_vcd_c.cpp $(TB).cpp obj_dir/V$(SV)__ALL.a -o $(EXE)

run: $(EXE)
	./$(EXE)

clean:
	rm -rf obj_dir $(EXE)

.PHONY: all run clean