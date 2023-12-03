# Should run from project root dir

echo "data/com.github.Rirusha.Cassette.desktop.in
data/com.github.Rirusha.Cassette.appdata.xml.in
data/com.github.Rirusha.Cassette.gschema.xml" > po/POTFILES.in

find . -type f \( -name '*.vala' -o -name '*.ui' \) -exec grep -lE 'translatable="true"|_\(|ngettext' {} + | sed 's|^\./||' >> po/POTFILES.in

xgettext --add-comments --files-from=po/POTFILES.in --output=po/en.pot

msguniq po/*.po -o po/*.po

msgmerge --add-location --backup=off --update po/*.po po/en.pot