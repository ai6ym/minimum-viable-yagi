SHELL := /bin/sh

MODELS := $(wildcard models/*.scad)
LIBRARIES := $(wildcard lib/*.scad)
STL_FILES := $(patsubst models/%.scad,build/stl/%.stl,$(MODELS))
PNG_FILES := $(patsubst models/%.scad,build/preview/%.png,$(MODELS))
DRIVEN_HOLDER_SOURCE := models/tape_yagi_driven_element_holder.scad
SHARED_YAGI_SOURCE := models/tape_yagi_element_holder.scad
HIGH_RES_FN ?= 96
HIGH_RES_TAPE_SEGMENTS ?= 32
HIGH_RES_STL_FILES := \
	build/stl-highres/tape_yagi_element_holder.stl \
	build/stl-highres/tape_yagi_driven_element_holder.stl
STANDARD_PRESET_STL_FILES := \
	build/stl-presets/tape_yagi_element_holder_pipe-0.5_tape-0.75.stl \
	build/stl-presets/tape_yagi_driven_element_holder_pipe-0.5_tape-0.75.stl \
	build/stl-presets/tape_yagi_element_holder_pipe-0.5_tape-1.0.stl \
	build/stl-presets/tape_yagi_driven_element_holder_pipe-0.5_tape-1.0.stl \
	build/stl-presets/tape_yagi_element_holder_pipe-0.5_tape-1.25.stl \
	build/stl-presets/tape_yagi_driven_element_holder_pipe-0.5_tape-1.25.stl \
	build/stl-presets/tape_yagi_element_holder_pipe-0.75_tape-0.75.stl \
	build/stl-presets/tape_yagi_driven_element_holder_pipe-0.75_tape-0.75.stl \
	build/stl-presets/tape_yagi_element_holder_pipe-0.75_tape-1.0.stl \
	build/stl-presets/tape_yagi_driven_element_holder_pipe-0.75_tape-1.0.stl \
	build/stl-presets/tape_yagi_element_holder_pipe-0.75_tape-1.25.stl \
	build/stl-presets/tape_yagi_driven_element_holder_pipe-0.75_tape-1.25.stl
HIGH_RES_PRESET_STL_FILES := \
	build/stl-highres/tape_yagi_element_holder_pipe-0.5_tape-0.75.stl \
	build/stl-highres/tape_yagi_driven_element_holder_pipe-0.5_tape-0.75.stl \
	build/stl-highres/tape_yagi_element_holder_pipe-0.5_tape-1.0.stl \
	build/stl-highres/tape_yagi_driven_element_holder_pipe-0.5_tape-1.0.stl \
	build/stl-highres/tape_yagi_element_holder_pipe-0.5_tape-1.25.stl \
	build/stl-highres/tape_yagi_driven_element_holder_pipe-0.5_tape-1.25.stl \
	build/stl-highres/tape_yagi_element_holder_pipe-0.75_tape-0.75.stl \
	build/stl-highres/tape_yagi_driven_element_holder_pipe-0.75_tape-0.75.stl \
	build/stl-highres/tape_yagi_element_holder_pipe-0.75_tape-1.0.stl \
	build/stl-highres/tape_yagi_driven_element_holder_pipe-0.75_tape-1.0.stl \
	build/stl-highres/tape_yagi_element_holder_pipe-0.75_tape-1.25.stl \
	build/stl-highres/tape_yagi_driven_element_holder_pipe-0.75_tape-1.25.stl

.DEFAULT_GOAL := help

.PHONY: help check test all stl stl-presets highres highres-presets preview clean

help:
	@echo "OpenSCAD workspace"
	@echo ""
	@echo "  make check    Check the OpenSCAD installation"
	@echo "  make test     Compile and validate every SCAD model"
	@echo "  make stl      Render every model to build/stl/"
	@echo "  make stl-presets  Render all supported sizes at standard resolution"
	@echo "  make highres  Render print-quality element-holder STLs"
	@echo "  make highres-presets  Render all supported sizes at high resolution"
	@echo "  make preview  Render PNG previews to build/preview/"
	@echo "  make all      Render STL files and PNG previews"
	@echo "  make clean    Remove generated files"

check:
	@./scripts/openscad --version

test:
	@./scripts/validate-scad

all: stl preview

stl: $(STL_FILES)

stl-presets: $(STANDARD_PRESET_STL_FILES)

highres: $(HIGH_RES_STL_FILES)

highres-presets: $(HIGH_RES_PRESET_STL_FILES)

preview: $(PNG_FILES)

build/stl/tape_yagi_driven_element_holder.stl: $(SHARED_YAGI_SOURCE)

build/preview/tape_yagi_driven_element_holder.png: $(SHARED_YAGI_SOURCE)

build/stl-highres/tape_yagi_driven_element_holder.stl: $(SHARED_YAGI_SOURCE)

build/stl-highres/%.stl: models/%.scad $(LIBRARIES) scripts/openscad
	@mkdir -p "$(@D)"
	./scripts/openscad -D '$$fn=$(HIGH_RES_FN)' \
		-D 'tape_curve_segments=$(HIGH_RES_TAPE_SEGMENTS)' -o "$@" "$<"

define STANDARD_ELEMENT_HOLDER_PRESET_RULE
build/stl-presets/$(1)_pipe-$(3)_tape-$(4).stl: models/$(1).scad $(2) $(LIBRARIES) scripts/openscad
	@mkdir -p "$$(@D)"
	./scripts/openscad -D 'pipe_nominal_inches=$(3)' \
		-D 'tape_width_inches=$(4)' -o "$$@" "$$<"
endef

define HIGH_RES_ELEMENT_HOLDER_PRESET_RULE
build/stl-highres/$(1)_pipe-$(3)_tape-$(4).stl: models/$(1).scad $(2) $(LIBRARIES) scripts/openscad
	@mkdir -p "$$(@D)"
	./scripts/openscad -D '$$$$fn=$(HIGH_RES_FN)' \
		-D 'tape_curve_segments=$(HIGH_RES_TAPE_SEGMENTS)' \
		-D 'pipe_nominal_inches=$(3)' -D 'tape_width_inches=$(4)' \
		-o "$$@" "$$<"
endef

define REGISTER_ELEMENT_HOLDER_PRESET
$(call STANDARD_ELEMENT_HOLDER_PRESET_RULE,tape_yagi_element_holder,,$(1),$(2))
$(call STANDARD_ELEMENT_HOLDER_PRESET_RULE,tape_yagi_driven_element_holder,$(SHARED_YAGI_SOURCE),$(1),$(2))
$(call HIGH_RES_ELEMENT_HOLDER_PRESET_RULE,tape_yagi_element_holder,,$(1),$(2))
$(call HIGH_RES_ELEMENT_HOLDER_PRESET_RULE,tape_yagi_driven_element_holder,$(SHARED_YAGI_SOURCE),$(1),$(2))
endef

$(eval $(call REGISTER_ELEMENT_HOLDER_PRESET,0.5,0.75))
$(eval $(call REGISTER_ELEMENT_HOLDER_PRESET,0.5,1.0))
$(eval $(call REGISTER_ELEMENT_HOLDER_PRESET,0.5,1.25))
$(eval $(call REGISTER_ELEMENT_HOLDER_PRESET,0.75,0.75))
$(eval $(call REGISTER_ELEMENT_HOLDER_PRESET,0.75,1.0))
$(eval $(call REGISTER_ELEMENT_HOLDER_PRESET,0.75,1.25))

build/stl/%.stl: models/%.scad $(LIBRARIES) scripts/openscad
	@mkdir -p "$(@D)"
	./scripts/openscad -o "$@" "$<"

build/preview/%.png: models/%.scad $(LIBRARIES) scripts/openscad
	@mkdir -p "$(@D)"
	./scripts/openscad --autocenter --viewall --imgsize=1200,900 -o "$@" "$<"

clean:
	rm -rf build
