#
# A simple way to get all the diagrams as SVG
#

DIAGRAMS := boot-1 boot-2 \
    build kernel debian_minimal_builder \

all: $(addsuffix .svg,$(DIAGRAMS))
all: $(addsuffix .pdf,$(DIAGRAMS))

clean:
	rm -f $(addsuffix .svg,$(DIAGRAMS))  $(addsuffix .pdf,$(DIAGRAMS))

%.svg: %.dot
	dot -Tsvg >$@ $<

%.pdf: %.dot
	dot -Tpdf >$@ $<

