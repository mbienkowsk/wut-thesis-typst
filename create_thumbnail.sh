(
    cd template || exit
    typst compile -f png --pages 1 --ppi 250 thesis.typ thumbnail.png
    oxipng thumbnail.png
)
mv template/thumbnail.png .
