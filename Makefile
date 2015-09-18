dissertation: completed analyse
	R -e 'library(knitr); knit("dissertation.Rnw")'
	pdflatex dissertation.tex
	biber --output_safechars dissertation
	pdflatex dissertation.tex

table:
	pdflatex table.tex

stim:
	pdflatex procedure/stimtest.tex

analyse:
	../opensesame/dotprobe/analyse.R

accuracy:
	../opensesame/dotprobe/accuracy.R > ../opensesame/dotprobe/accuracy.tt

completed:
	../opensesame/dotprobe/completed.pl > results/completed.tex

test_completed: completed
	pdflatex results/completed.tex

diary:
	pdflatex diary.tex
	biber --output_safechars diary
	pdflatex diary.tex
