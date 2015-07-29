dissertation:
	pdflatex dissertation.tex
	biber --output_safechars dissertation
	pdflatex dissertation.tex

