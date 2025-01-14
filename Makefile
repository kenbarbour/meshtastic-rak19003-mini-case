# Configurable variables
SCAD_COMPILER ?= openscad
SLICER ?= slic3r

# Patterns
SCAD_FILES := $(wildcard ./*.scad)
STL_FILES := $(patsubst ./%.scad,./%.stl,$(SCAD_FILES))
GCODE_FILES := $(patsubst ./%.stl,./%.gcode,$(STL_FILES))

# Recipes
.PHONY: all clean models help

all: $(GCODE_FILES)

models: $(STL_FILES)

# Convert .scad to .stl
%.stl: %.scad
	$(SCAD_COMPILER) -o $@ $<

# Slice .stl to .gcode
%.gcode: %.stl
	$(SLICER) $< --output $@

clean:
	rm -rf *.stl *.gcode

help:
	@echo "Makefile for 3D Printing Projects"
	@echo
	@echo "Usage:"
	@echo "  make all       Build all .gcode files from .scad sources."
	@echo "  make clean     Remove all generated .stl and .gcode files."
	@echo "  make models    Build all .stl files from .scad sources."
	@echo "  make help      Show this help message."
	@echo
	@echo "Configurable Variables (current values):"
	@echo "  SCAD_COMPILER  = $(SCAD_COMPILER)"
	@echo "  SLICER         = $(SLICER)"
