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
	@test -d vendor || mkdir -p vendor
	@if ! test -f "{{ligature_font_file}}"; then \
		echo "file not found: \"{{ligature_font_file}}\""; exit 1; fi
	@test -f vendor/base.otf || curl -sL -o vendor/base.otf \
		'https://github.com/shannpersand/comic-shanns/raw/master/v2/comic%20shanns.otf'
	@test -f vendor/base.ttf || curl -sL -o vendor/base.ttf \
		'https://github.com/shannpersand/comic-shanns/raw/master/v2/comic%20shanns%202.ttf'
	@test -f vendor/ref.ttf || curl -sL -o vendor/ref.ttf \
		'https://github.com/google/fonts/raw/main/apache/cousine/Cousine-Regular.ttf'

[private]
generate: download
	rm -rf "{{tmp}}"
	mkdir -p vendor "{{tmp}}"
	python generate.py "{{tmp}}" 'otf' "{{ref_font_file}}"

[doc("build fonts")]
build: generate
	#!/usr/bin/env bash
	rm -rf "{{output}}"
	mkdir -p "{{output}}"
	ligaturize() {
		fontforge -lang py -script "{{ligaturize_py}}" "$1" \
			--output-dir="$PWD/{{output}}" \
			--prefix="$2" \
			--ligature-font-file="{{ligature_font_file}}"
	}
	for f in "{{tmp}}"/*; do
		ligaturize "$f" ''
	done

[doc("install fonts")]
install:
	rm -rf "$HOME"/.local/share/fonts/Komiki
	mkdir -p "$HOME"/.local/share/fonts/Komiki
	cp -t "$HOME"/.local/share/fonts/Komiki "{{output}}"/*
	fc-cache -f
