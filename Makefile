all: paper.pdf

clean:
	rm paper.aux
	rm paper.bbl

format:
	biber --tool --configfile=biber.conf --collate --output-align --output-indent=4 --fixinits -O paper.bib paper.bib

paper.aux: paper.tex $(shell find figures)
	pdflatex paper

paper.bbl: paper.aux paper.bib
	bibtex paper

paper.pdf: paper.aux paper.bbl
	pdflatex paper
	pdflatex paper

