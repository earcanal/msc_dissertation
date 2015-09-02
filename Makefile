dissertation: completed
	R -e 'library(knitr); knit("dissertation.Rnw")'
	pdflatex dissertation.tex
	biber --output_safechars dissertation
	pdflatex dissertation.tex

table:
	pdflatex table.tex

accuracy:
	../opensesame/dotprobe/accuracy.R > ../opensesame/dotprobe/accuracy.tt

completed:
	../opensesame/dotprobe/completed.pl > results/completed.tex

test_completed: completed
	pdflatex results/completed.tex

