#!/bin/sh
for i in `seq 31 64`;
do
    echo "Rscript -e \"rmarkdown::render('profiles.Rmd', params = list(data=$i))\""
    Rscript -e "rmarkdown::render('profiles.Rmd', params = list(data=$i))"
    echo "mv profiles.pdf $i.pdf"
    mv profiles.pdf $i.pdf
done
