
SRC = src
BIN = bin
BLD = build
DOCS = docs

OCAMLC = ocamlopt # Compiler
OCAMLDOC = ocamldoc # Documentation generator
OCAMLCFLAGS = -g -I $(BLD) # Flags de compilation
OCAMLDOCFLAGS = -latex -d $(DOCS) -I $(BLD) -o $(DOCS)/docs_compression.tex -colorize-code -t "Compression Algorithms Project Documentation"

TARGETS = $(BIN)/dumpbits $(BIN)/decompresshuffman $(BIN)/compresshuffman $(BIN)/compresslzw $(BIN)/decompresslzw # Cibles

SOURCES = $(SRC)/CompressHuffman.ml $(SRC)/DecompressHuffman.ml $(SRC)/CompressLZW.ml $(SRC)/DecompressLZW.ml $(SRC)/DumpBits.ml $(SRC)/PriorityQueue.mli $(SRC)/PriorityQueue.ml $(SRC)/BitChannel.mli $(SRC)/BitChannel.ml # Fichiers sources

OBJECTS = $(BLD)/BitChannel.cmx $(BLD)/PriorityQueue.cmx # Fichiers objets

# Default rule
all: $(TARGETS) docs

# Link the executable files i.e. $(TARGETS)
$(BIN)/decompresshuffman: $(OBJECTS) $(BLD)/DecompressHuffman.cmx 
	@mkdir -p $(BIN)
	$(OCAMLC) $(OCAMLCFLAGS) -o $@ $^ 

$(BIN)/compresshuffman: $(OBJECTS) $(BLD)/CompressHuffman.cmx
	@mkdir -p $(BIN)
	$(OCAMLC) $(OCAMLCFLAGS) -o $@ $^ 

$(BIN)/compresslzw: $(OBJECTS) $(BLD)/CompressLZW.cmx 
	@mkdir -p $(BIN)
	$(OCAMLC) $(OCAMLCFLAGS) -o $@ $^ 

$(BIN)/decompresslzw: $(OBJECTS) $(BLD)/DecompressLZW.cmx 
	@mkdir -p $(BIN)
	$(OCAMLC) $(OCAMLCFLAGS) -o $@ $^ 

$(BIN)/dumpbits: $(OBJECTS) $(BLD)/DumpBits.cmx
	@mkdir -p $(BIN)
	$(OCAMLC) $(OCAMLCFLAGS) -o $@ $^

# Compilation of .mli and .ml files
$(BLD)/PriorityQueue.cmx: $(SRC)/PriorityQueue.ml $(BLD)/PriorityQueue.cmi
	@mkdir -p $(BLD)
	$(OCAMLC) $(OCAMLCFLAGS) -c -o $@ $<

$(BLD)/PriorityQueue.cmi: $(SRC)/PriorityQueue.mli
	@mkdir -p $(BLD)
	$(OCAMLC) $(OCAMLCFLAGS) -c -o $@ $<

$(BLD)/BitChannel.cmx: $(SRC)/BitChannel.ml $(BLD)/BitChannel.cmi
	@mkdir -p $(BLD)
	$(OCAMLC) $(OCAMLCFLAGS) -c -o $@ $<

$(BLD)/BitChannel.cmi: $(SRC)/BitChannel.mli
	@mkdir -p $(BLD)
	$(OCAMLC) $(OCAMLCFLAGS) -c -o $@ $<

$(BLD)/DecompressHuffman.cmx: $(SRC)/DecompressHuffman.ml $(BLD)/BitChannel.cmi
	@mkdir -p $(BLD)
	$(OCAMLC) $(OCAMLCFLAGS) -c -o $@ $<

$(BLD)/CompressHuffman.cmx: $(SRC)/CompressHuffman.ml $(BLD)/PriorityQueue.cmi $(BLD)/BitChannel.cmi
	@mkdir -p $(BLD)
	$(OCAMLC) $(OCAMLCFLAGS) -c -o $@ $<

$(BLD)/DumpBits.cmx: $(SRC)/DumpBits.ml $(BLD)/BitChannel.cmi 
	@mkdir -p $(BLD)
	$(OCAMLC) $(OCAMLCFLAGS) -c -o $@ $<

$(BLD)/DecompressLZW.cmx: $(SRC)/DecompressLZW.ml $(BLD)/BitChannel.cmi
	@mkdir -p $(BLD)
	$(OCAMLC) $(OCAMLCFLAGS) -c -o $@ $<

$(BLD)/CompressLZW.cmx: $(SRC)/CompressLZW.ml $(BLD)/BitChannel.cmi
	@mkdir -p $(BLD)
	$(OCAMLC) $(OCAMLCFLAGS) -c -o $@ $<

# Generation of documentation
docs: $(SOURCES)
	@mkdir -p $(DOCS)
	$(OCAMLDOC) $(OCAMLDOCFLAGS) -intro misc/doc_intro.txt $(SOURCES)
	cd $(DOCS) && awk 'NR==2{print "\\author{Grimaud}"}1' docs_compression.tex > temp && mv temp docs_compression.tex && pdflatex docs_compression.tex && pdflatex docs_compression.tex && pdflatex docs_compression.tex
	rm $(DOCS)/*.aux $(DOCS)/*.toc $(DOCS)/*.log

# Clean generated files
clean:
	rm -f $(BLD)/*.cm[ix] $(BLD)/*.o $(TARGETS)
	rm -f *~ $(SRC)/*~
	rm -rf $(BLD) $(DOCS)
	rm examples/*.huffman examples/*.lzw

.PHONY: all clean docs

