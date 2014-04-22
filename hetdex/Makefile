all: talk.pdf


.PHONY: always

%.pdf: %.tex always
	latexmk -pdf -pdflatex='pdflatex -halt-on-error %O %S' $<
