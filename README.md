# Komiki Mono

[Comic Mono](https://github.com/dtinth/comic-mono-font) fork using
[Comic Shanns v2](https://github.com/shannpersand/comic-shanns) as base with 
[ligatures](https://github.com/ToxicFrog/Ligaturizer).

The font families are called `Komiki Mono` and `Komiki Mono Zero`.

## Download

- [Komiki Mono Zero Regular](https://github.com/salif/komiki-mono/releases/download/v1.2024.813/KomikiMonoZero-Regular.otf)
- [Komiki Mono Zero Bold](https://github.com/salif/komiki-mono/releases/download/v1.2024.813/KomikiMonoZero-Bold.otf)
- [Komiki Mono Regular](https://github.com/salif/komiki-mono/releases/download/v1.2024.813/KomikiMono-Regular.otf)
- [Komiki Mono Bold](https://github.com/salif/komiki-mono/releases/download/v1.2024.813/KomikiMono-Bold.otf)

## Preview

![Font Preview](preview.png)

## Recommended settings

### Visual Studio Code

```json
{
    "editor.fontFamily": "'Komiki Mono Zero', monospace",
    "editor.fontSize": 14.5,
    "editor.fontLigatures": true
}
```

## Development

Requires `just` and `ligaturizer`.

```sh
just --set ligature_font_file \
    /usr/share/fonts/OTF/FiraCode-Regular.otf build
```

Fonts are inside `./output`.

## License and Attributions

This project is released under the MIT license.
Check out the [LICENSE](LICENSE) file for more information.

[Komisch Mono](https://github.com/marcelhas/komisch-mono-font) was used as reference.
