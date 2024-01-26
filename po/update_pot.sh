#!/bin/bash
# Should run from project root dir

version=$(grep -F "version: " ./meson.build | grep -v "meson" | grep -o "'.*'" | sed "s/'//g")

find ./src -iname "*.vala" | xargs xgettext --add-comments --package-name=Cassette --package-version="$version" --from-code=UTF-8 --output=./po/cassette-src.pot
find ./data/ui -iname "*.ui" | xargs xgettext --add-comments --package-name=Cassette --package-version="$version" --from-code=UTF-8 --output=./po/cassette-old-ui.pot
find ./data/ui -iname "*.blp" | xargs xgettext --add-comments --package-name=Cassette --package-version="$version" --from-code=UTF-8 --output=./po/cassette-blueprint.pot --keyword=_ --keyword=C_:1c,2 -L C
find ./data/ -iname "*.desktop.in" | xargs xgettext --add-comments --package-name=Cassette --package-version="$version" --from-code=UTF-8 --output=./po/cassette-desktop.pot -L Desktop
find ./data/ -iname "*.appdata.xml.in" | xargs xgettext --no-wrap --package-name=Cassette --package-version="$version" --from-code=UTF-8 --output=./po/cassette-appdata.pot

msgcat --sort-by-file --use-first --output-file=./po/cassette.pot ./po/cassette-src.pot ./po/cassette-old-ui.pot ./po/cassette-blueprint.pot ./po/cassette-desktop.pot ./po/cassette-appdata.pot

sed 's/#: //g;s/:[0-9]*//g;s/\.\.\///g' <(grep -F "#: " po/cassette.pot) | sed s/\ /\\n/ | sort | uniq > ./po/POTFILES.in

rm ./po/cassette-*.pot

echo "# Please keep this list alphabetically sorted" > ./po/LINGUAS
for l in $(ls ./po/*.po); do basename $l .po >> ./po/LINGUAS; done

for file in ./po/*.po; do
    msgmerge --update --backup=none "$file" ./po/cassette.pot
    msguniq "$file" -o "$file"
done

# To create language file use this command
# msginit --locale=LOCALE --input cassette.pot
# where LOCALE is something like `de`, `it`, `es`...
# or use Poedit with "Create new"
