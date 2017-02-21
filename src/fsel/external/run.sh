#!/bin/bash

for i in {2..30}
do
    echo "Rscript --vanilla ssga-fsel.r $i"
    Rscript --vanilla ssga-fsel.r $i
done
