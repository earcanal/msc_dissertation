dissertation:
	R -e 'library(knitr); knit("dissertation.Rnw")'
	pdflatex dissertation.tex
	biber --output_safechars dissertation
	pdflatex dissertation.tex

