# This makefile generates HEX and Dump files for RV32UI tests
# from the RISCV Foundation's riscv_tests project.
#
# This makefile requires that RISCV_TESTS be set to the location where the
# riscv_test repository has been cloned and installed
# (see https://github.com/riscv/riscv-tests).

ARCH ?= i
ABI  ?= ilp32
ROOT_DIR := $(shell pwd)
RUNTIME_REL_BUILD_DIR := ../riscv_tests_hexgen/build
BUILD_DIR := $(ROOT_DIR)/build
OBJ_DIR := $(BUILD_DIR)/obj
RISCV_ISA_SRC_DIR := $(RISCV_TESTS)/isa
S_FILES := $(shell ls $$RISCV_TESTS/isa/rv32ui/*.S)
TESTS := $(patsubst %.S, %, $(notdir $(S_FILES)))
OBJ := $(addprefix $(OBJ_DIR)/,$(TESTS:%=%.o))
ELF := $(addprefix $(BUILD_DIR)/,$(TESTS:%=%.elf))
HEX := $(addprefix $(BUILD_DIR)/,$(TESTS:%=%.hex))
HEX_SIM := $(addprefix $(RUNTIME_REL_BUILD_DIR)/,$(TESTS:%=%.hex))
DUMP := $(addprefix $(BUILD_DIR)/,$(TESTS:%=%.dump))

RISCV_GCC_PREFIX ?= riscv32-unknown-elf-
RISCV_GCC := $(RISCV_GCC_PREFIX)gcc
RISCV_OBJDUMP ?= $(RISCV_GCC_PREFIX)objdump -D
RISCV_OBJCOPY ?= $(RISCV_GCC__PREFIX)objcopy -O verilog
RISCV_GCC_OPTS ?= -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles
CFLAGS := -I$(RISCV_ISA_SRC_DIR)/../env/p -I$(RISCV_ISA_SRC_DIR)/macros/scalar -DASM -Wa,-march=rv32$(ARCH) -march=rv32$(ARCH) -mabi=$(ABI) -D__riscv_xlen=32 
#link file is a copy of $(RISCV_ISA_SRC_DIR)/../env/p/link.ld, with a 0 start address
LDFLAGS := $(RISCV_GCC_OPTS) -Tlink.ld -march=rv32$(ARCH) -mabi=$(ABI)

default: $(ELF) $(HEX) $(DUMP) hex_file_list

hex_file_list: $(BUILD_DIR)
	@echo $(HEX_SIM) > $(BUILD_DIR)/hex_files.txt

define compile_template
$(OBJ_DIR)/$$(basename $(notdir $(SRC))).o: $$(SRC) | $(OBJ_DIR)
	$(RISCV_GCC) -c $$< $(CFLAGS) -o $$@
 endef

$(foreach SRC,$(S_FILES), $(eval $(compile_template)))

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

$(OBJ_DIR) : $(BUILD_DIR)
	mkdir -p $(OBJ_DIR)

$(BUILD_DIR)/%.elf: $(OBJ_DIR)/%.o | $(OBJ_DIR)
	$(RISCV_GCC) $^ $(LDFLAGS) -o $@

$(BUILD_DIR)/%.hex: $(BUILD_DIR)/%.elf
	$(RISCV_OBJCOPY) $^ $@

$(BUILD_DIR)/%.dump: $(BUILD_DIR)/%.elf
	$(RISCV_OBJDUMP) $^ > $@


clean:
	rm -rf $(BUILD_DIR)
