# Configurable variables
SCAD_COMPILER ?= openscad
SLICER ?= slic3r
SLICER_OPTS ?= 

# Directories
SCAD_DIR := scad
PARTS_DIR := $(SCAD_DIR)/parts
LIB_DIR := $(SCAD_DIR)/lib
MODELS_DIR := models

# Patterns
PARTS := $(wildcard $(PARTS_DIR)/*.scad)
PART_NAMES := $(notdir $(basename $(PARTS)))
STL_FILES := $(patsubst $(PARTS_DIR)/%.scad,$(MODELS_DIR)/%.stl,$(PARTS))
GCODE_FILES := $(patsubst $(MODELS_DIR)/%.stl,$(MODELS_DIR)/%.gcode,$(STL_FILES))

# Recipes
.PHONY: all clean models help list-parts

all: $(GCODE_FILES)

models: $(STL_FILES)

build-%: $(MODELS_DIR)/%.stl

# Slice specific part by name
slice-%: $(MODELS_DIR)/%.gcode

# Convert .scad to .stl
$(MODELS_DIR)/%.stl: $(PARTS_DIR)/%.scad
	mkdir -p $(MODELS_DIR)
	$(SCAD_COMPILER) -o $@ $<

# Slice .stl to .gcode
$(MODELS_DIR)/%.gcode: $(MODELS_DIR)/%.stl
	$(SLICER) $(SLICER_OPTS) $< --output $@

clean:
	rm -rf $(MODELS_DIR)

help:
	@echo "Makefile for 3D Printing Projects"
	@echo
	@echo "Usage:"
	@echo "  make all           Build all .gcode files from .scad sources in $(PARTS_DIR)."
	@echo "  make models        Build all .stl files from .scad sources in $(PARTS_DIR)."
	@echo "  make build-<part>  Build the specified part (e.g., 'make build-widget' for widget.scad)."
	@echo "  make slice-<part>  Slice the specified part (e.g., 'make slice-widget' for widget.scad)."
	@echo "  make clean         Remove all generated .stl and .gcode files."
	@echo "  make list-parts    List all available parts in $(PARTS_DIR)."
	@echo "  make help          Show this help message."
	@echo
	@echo "Configurable Variables (current values):"
	@echo "  SCAD_COMPILER    = $(SCAD_COMPILER)"
	@echo "  SLICER           = $(SLICER)"
	@echo "  SCAD_DIR         = $(SCAD_DIR)"
	@echo "  PARTS_DIR        = $(PARTS_DIR)"
	@echo "  MODELS_DIR       = $(MODELS_DIR)"

list-parts:
	@echo "Available parts:"
	@for part in $(PART_NAMES); do \
		echo "  $$part"; \
	done

