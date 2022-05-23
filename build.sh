#!/bin/sh
if [-d "output"]
then
    echo "Output directory exists"
else
    echo "No output dir, creating directory"
    mkdir output
fi
pdflatex -halt-on-error --output-directory=./output main
mv output/main.pdf ./

mkdir temp
mv build.sh temp/
mv main.pdf temp/
mv main.tex temp/
rm -rf main.* texput.log
mv temp/build.sh ./
mv temp/main.pdf ./
mv temp/main.tex ./
rm -rf temp