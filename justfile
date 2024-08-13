#!/usr/bin/env -S just -f

ligaturize_py := '/usr/share/ligaturizer/ligaturize.py'
ligature_font_file := 'vendor/JetBrainsMono-Regular.ttf'
ref_font_file := 'vendor/ref.ttf'
tmp := 'tmp'
output := 'output'

_:
	@just --list

[private]
clean:
	rm -rf "{{tmp}}" "{{output}}"

[doc("download fonts")]
download:
	@if ! test -d vendor; then mkdir -p vendor; fi
	@if ! test -f "{{ligature_font_file}}"; then \
		echo "file not found: \"{{ligature_font_file}}\""; exit 1; fi
	@test -f vendor/base_zero.otf || curl -sL -o vendor/base_zero.otf \
		'https://github.com/shannpersand/comic-shanns/raw/master/v2/comic%20shanns.otf'
	@test -f vendor/ref.ttf || curl -sL -o vendor/ref.ttf \
		'https://github.com/google/fonts/raw/main/apache/cousine/Cousine-Regular.ttf'

[private]
generate: download
	@rm -rf "{{tmp}}"
	@mkdir -p vendor "{{tmp}}"
	just generate-do "{{tmp}}" 'vendor/base_zero.otf' 'otf' "{{ref_font_file}}" 'Zero' ' Zero'
	if test -f 'vendor/base.otf'; then \
		just generate-do "{{tmp}}" 'vendor/base.otf' 'otf' "{{ref_font_file}}" '' ''; fi

[doc("build fonts")]
build: generate
	@if test -d "{{output}}"; then \
		rm -r "{{output}}"; fi
	@mkdir -p "{{output}}"
	for f in "{{tmp}}"/*; do \
		just ligaturize "$f" ''; done

ligaturize file prefix:
	fontforge -lang py -script "{{ligaturize_py}}" "{{file}}" \
		--output-dir="$PWD/{{output}}" \
		--prefix="{{prefix}}" \
		--ligature-font-file="{{ligature_font_file}}"

[doc("install fonts")]
install:
	@if test -d "$HOME"/.local/share/fonts/Komiki; then \
		rm -r "$HOME"/.local/share/fonts/Komiki; fi
	@mkdir -p "$HOME"/.local/share/fonts/Komiki;
	cp -t "$HOME"/.local/share/fonts/Komiki "{{output}}"/*
	fc-cache -f

[private]
generate-do outdir base ext ref basename name:
	#!/usr/bin/env python3
	#
	"""
	Generates the Comic Mono font files based on Comic Shanns font.

	Based on:
	- monospacifier: https://github.com/cpitclaudel/monospacifier/blob/master/monospacifier.py
	- YosemiteAndElCapitanSystemFontPatcher: https://github.com/dtinth/YosemiteAndElCapitanSystemFontPatcher/blob/master/bin/patch
	"""
	#
	import os
	import sys
	import fontforge
	import psMat
	import unicodedata
	#
	OUTDIR = "{{outdir}}"
	EXT = "{{ext}}"
	#
	if not os.path.isdir(OUTDIR):
	    print(f"Given path '{OUTDIR}' is not a directory!")
	    sys.exit(1)
	#
	def height(font):
	    return float(font.capHeight)
	#
	def adjust_height(source, template):
	    source.transform(psMat.scale(height(template) / height(source)))
	    for attr in ['ascent', 'descent',
	                'hhea_ascent', 'hhea_ascent_add',
	                'hhea_linegap',
	                'hhea_descent', 'hhea_descent_add',
	                'os2_winascent', 'os2_winascent_add',
	                'os2_windescent', 'os2_windescent_add',
	                'os2_typoascent', 'os2_typoascent_add',
	                'os2_typodescent', 'os2_typodescent_add',
	                ]:
	        setattr(source, attr, getattr(template, attr))
	#
	font = fontforge.open("{{base}}")
	ref = fontforge.open("{{ref}}")
	for g in font.glyphs():
	    uni = g.unicode
	    category = unicodedata.category(chr(uni)) if 0 <= uni <= sys.maxunicode else None
	    if g.width > 0 and category not in ['Mn', 'Mc', 'Me']:
	        target_width = 550
	        if g.width != target_width:
	            delta = target_width - g.width
	            g.left_side_bearing = int(round(g.left_side_bearing + delta / 2.0))
	            g.right_side_bearing = int(round(g.right_side_bearing + delta - g.left_side_bearing))
	            g.width = target_width

	font.version = '1.0.0'
	font.comment = 'https://github.com/salif/komiki-mono'
	font.copyright = 'https://github.com/salif/komiki-mono/blob/main/LICENSE'
	font.sfnt_names = []
	#
	font.selection.all()
	adjust_height(font, ref)
	font.familyname = 'Komiki Mono{{name}}'
	font.fontname = 'KomikiMono{{basename}}-Regular'
	font.fullname = 'Komiki Mono{{name}} Regular'
	font.weight = 'Normal'
	font.os2_weight = 400
	font.generate(f'{OUTDIR}/Komiki-mono{{basename}}-regular.{EXT}')
	#
	font.selection.all()
	font.fontname = 'KomikiMono{{basename}}-Bold'
	font.fullname = 'Komiki Mono{{name}} Bold'
	font.weight = 'Bold'
	font.os2_weight = 700
	font.changeWeight(32, "LCG", 0, 0, "squish")
	font.generate(f'{OUTDIR}/Komiki-mono{{basename}}-bold.{EXT}')
	font.close()
	ref.close()
