### Makefile (generic beamer/LaTeX)
# Usage:
#   make            # build PDF (multi-pass)
#   make watch      # latexmk continuous build (if installed)
#   make view       # open PDF with OS default viewer
#   make clean      # remove build artifacts
#   make distclean  # remove build/ and output PDF
#
# Assumes main file is $(PROJECT).tex (default: main.tex)

PROJECT ?= main

# Directories
BUILD_DIR ?= build
OUT_DIR   ?= output

# Engines/tools
LATEX     ?= pdflatex
BIBER     ?= biber
LATEXMK   ?= latexmk

# Flags
LATEX_FLAGS ?= -halt-on-error -interaction=nonstopmode -file-line-error -output-directory=$(BUILD_DIR)

# OS detection for viewer
UNAME := $(shell uname)
ifeq ($(UNAME),Darwin)
PDFVIEWER ?= open
else
PDFVIEWER ?= xdg-open
endif

# Inputs (dependency scan)
TEX_FILES := $(shell find . -maxdepth 5 \( -name '*.tex' -o -name '*.sty' -o -name '*.cls' -o -name '*.bbx' -o -name '*.cbx' \))
BIB_FILES := $(shell find . -maxdepth 5 -name '*.bib')
IMG_FILES := $(shell find . -maxdepth 5 \( -name '*.png' -o -name '*.jpg' -o -name '*.jpeg' -o -name '*.pdf' \) )

PDF_OUT   := $(OUT_DIR)/$(PROJECT).pdf
PDF_BUILD := $(BUILD_DIR)/$(PROJECT).pdf

.PHONY: all default view clean distclean watch dirs
default: all
all: $(PDF_OUT)

dirs:
	@mkdir -p $(BUILD_DIR) $(OUT_DIR)

# Core build: mimic your script (pdflatex/biber/pdflatex/pdflatex),
# but only run biber if bib files exist.
$(PDF_BUILD): $(PROJECT).tex $(TEX_FILES) $(BIB_FILES) $(IMG_FILES) | dirs
	@echo "==> LaTeX pass 1"
	$(LATEX) $(LATEX_FLAGS) $(PROJECT)
	@if [ -n "$(BIB_FILES)" ]; then \
		echo "==> Biber pass 1"; \
		$(BIBER) $(BUILD_DIR)/$(PROJECT); \
		echo "==> LaTeX pass 2"; \
		$(LATEX) $(LATEX_FLAGS) $(PROJECT); \
		echo "==> Biber pass 2"; \
		$(BIBER) $(BUILD_DIR)/$(PROJECT); \
	fi
	@echo "==> LaTeX pass (final x2)"
	$(LATEX) $(LATEX_FLAGS) $(PROJECT)
	$(LATEX) $(LATEX_FLAGS) $(PROJECT)
	@echo "==> Built: $(PDF_BUILD)"

# Copy the final PDF to output/
$(PDF_OUT): $(PDF_BUILD) | dirs
	@cp -f $(PDF_BUILD) $(PDF_OUT)
	@echo "==> Output: $(PDF_OUT)"

# Open PDF
view: $(PDF_OUT)
	@$(PDFVIEWER) "$(PDF_OUT)" >/dev/null 2>&1 &

# Optional: continuous build (nice for Beamer). Requires latexmk.
watch: | dirs
	@command -v $(LATEXMK) >/dev/null 2>&1 || { echo "latexmk not found"; exit 1; }
	$(LATEXMK) -pdf -pdflatex="$(LATEX) $(LATEX_FLAGS)" -usebiber -outdir=$(BUILD_DIR) -pvc $(PROJECT).tex

# Clean build artifacts
clean:
	@rm -rf $(BUILD_DIR)
	@echo "==> Removed $(BUILD_DIR)/"

# Remove build + generated PDFs
distclean: clean
	@rm -rf $(OUT_DIR)
	@echo "==> Removed $(OUT_DIR)/"
