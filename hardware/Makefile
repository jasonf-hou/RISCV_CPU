# Set the project name and directories
TOP := ml505top
SRC := src
TEMPLATES := cfg

TARGETS = all synth xst map par timing bitgen impact report schematic schem ise

BUILDDIR := build/$(TOP)
SIMDIR   := sim
MAKEFILE := $(BUILDDIR)/Makefile
MAKEARGS := TOP=$(TOP) SRC=../../$(SRC) TEMPLATES=../../$(TEMPLATES)

$(TARGETS): $(MAKEFILE)
	$(MAKE) $@ -C $(BUILDDIR) $(MAKEARGS)

$(MAKEFILE): cfg/Makefile
	mkdir -p build/$(TOP)
	cp $< $@

.PHONY: sim
sim:
	$(MAKE) -C $(SIMDIR)

clean:
	rm -rf build $(SIMDIR)/results $(SIMDIR)/build

.PHONY := $(TARGETS) clean
