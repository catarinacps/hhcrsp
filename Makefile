OUT_DIR := build
SRC_DIR := src

JULIA_PATH ?= ~/.julia

JC := julia $(shell find $(JULIA_PATH) -name juliac.jl)

################################################################################
#	Files:

#	- Path to all final binaries:
TARGET := $(OUT_DIR)/hhcrsp

################################################################################
#	Targets:

.DEFAULT_GOAL = all

all: $(TARGET)

#
# executable
#
$(OUT_DIR)/hhcrsp: $(SRC_DIR)/hhcrsp.jl
	COMPILE_BUILD=true $(JC) -vaer -d $(OUT_DIR) $^

#
# misc
#
print-%:
	@echo $* = $($*)

clean:
	rm -rf $(OUT_DIR)/* *~
