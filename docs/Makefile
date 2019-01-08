#
# A simple way to get all the diagrams as SVG
#

DIAGRAMS := boot-1 boot-2 \
    build kernel debian_minimal_builder \

TOP_DIR ?= $(abspath ..)
OUT_DIR ?= $(TOP_DIR)/output-docs

all: $(addprefix $(OUT_DIR)/,$(addsuffix .svg,$(DIAGRAMS)))
all: $(addprefix $(OUT_DIR)/,$(addsuffix .pdf,$(DIAGRAMS)))

build-depends:
	sudo apt install -y graphviz

clean:
	rm -rf $(OUT_DIR)

reallyclean: clean

$(OUT_DIR)/%.svg: %.dot $(OUT_DIR)
	dot -Tsvg >$@ $<

$(OUT_DIR)/%.pdf: %.dot $(OUT_DIR)
	dot -Tpdf >$@ $<

$(OUT_DIR): $(addsuffix .dot,$(DIAGRAMS)) index.html
	mkdir -p $(OUT_DIR)
	cp -f $^ $@
