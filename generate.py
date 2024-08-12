#!/usr/bin/env python3

"""
Generates the Comic Mono font files based on Comic Shanns font.

Based on:
- monospacifier: https://github.com/cpitclaudel/monospacifier/blob/master/monospacifier.py
- YosemiteAndElCapitanSystemFontPatcher: https://github.com/dtinth/YosemiteAndElCapitanSystemFontPatcher/blob/master/bin/patch
"""

import os
import re
import sys

import fontforge
import psMat
import unicodedata

OUTDIR = sys.argv[1]
EXT = sys.argv[2]
REF = sys.argv[3]

if not os.path.isdir(OUTDIR):
    print(f"Given path '{OUTDIR}' is not a directory!")
    sys.exit(1)

def height(font):
    return float(font.capHeight)

def adjust_height(source, template, scale):
    source.selection.all()
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
    source.transform(psMat.scale(scale))

font = fontforge.open(f'vendor/base.{EXT}')
ref = fontforge.open(REF)
for g in font.glyphs():
    uni = g.unicode
    category = unicodedata.category(chr(uni)) if 0 <= uni <= sys.maxunicode else None
    if g.width > 0 and category not in ['Mn', 'Mc', 'Me']:
        target_width = 510
        if g.width != target_width:
            delta = target_width - g.width
            g.left_side_bearing = int(round(g.left_side_bearing + delta / 2.0))
            g.right_side_bearing = int(round(g.right_side_bearing + delta - g.left_side_bearing))
            g.width = target_width

font.version = '1.0.0'
font.comment = 'https://github.com/salif/komiki-mono'
font.copyright = 'https://github.com/salif/komiki-mono/blob/main/LICENSE'
font.sfnt_names = []

font.familyname = 'Komiki Mono Shanns'
font.fontname = 'KomikiMonoShanns-Regular'
font.fullname = 'Komiki Mono Shanns Regular'
font.generate(f'{OUTDIR}/Komiki-mono-shanns.{EXT}')

adjust_height(font, ref, 1.125)
font.familyname = 'Komiki Mono'
font.fontname = 'KomikiMono-Regular'
font.fullname = 'Komiki Mono Regular'
font.weight = 'Normal'
font.os2_weight = 400
font.generate(f'{OUTDIR}/Komiki-mono-regular.{EXT}')
