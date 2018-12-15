#
# A simple way to get all the diagrams as SVG
#

DIAGRAMS := boot-1 boot-2 \
    build kernel debian_minimal_builder \

TOP_DIR ?= $(abspath ..)

all: $(addsuffix .svg,$(DIAGRAMS))
all: $(addsuffix .pdf,$(DIAGRAMS))
	mkdir -p $(TOP_DIR)/output-docs
	cp *.dot *.html *.pdf *.svg $(TOP_DIR)/output-docs

build-depends:
	sudo apt install -y graphviz

clean:
	rm -f $(addsuffix .svg,$(DIAGRAMS))  $(addsuffix .pdf,$(DIAGRAMS))
	rm -f $(TOP_DIR)/output-docs/*

reallyclean: clean

%.svg: %.dot
	dot -Tsvg >$@ $<

%.pdf: %.dot
	dot -Tpdf >$@ $<

