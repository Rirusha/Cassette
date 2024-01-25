# Should run from project root dir

echo "data/io.github.Rirusha.Cassette.desktop.in
data/io.github.Rirusha.Cassette.appdata.xml.in
data/io.github.Rirusha.Cassette.gschema.xml" > po/POTFILES.in

find . -type f \( -name '*.vala' -o -name '*.ui' \) ! -path './.flatpak/*' ! -path './_build/*' -exec grep -lE 'translatable="true"|_\(|ngettext' {} + | sed 's|^\./||' >> po/POTFILES.in

xgettext --add-comments --files-from=po/POTFILES.in --output=po/en.pot --from-code=UTF-8

msguniq po/en.pot -o po/en.pot
