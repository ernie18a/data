# TS | Velgo Watermark

- url: https://www.tradingview.com/script/dJJUlr8b/
- type: indicator
- pine_id: PUB;2c48a0b3cc634f148cca0b877575532c
- version: 2.0

## Description

Zeigt die Logos von Trading Strategen und Velgo.ai als dezentes Wasserzeichen direkt im Chart an – ohne Signale, ohne Einfluss auf die Analyse.

Einstellungen:

[list]
[*]Position (9 Optionen)
[*]Transparenz
[*]Schriftgröße für Titel und Untertitel
[*]Farben individuell anpassbar
[*]Optionaler Hintergrundkasten mit eigener Farbe
[/list]
Ideal zur Verwendung in Screenshots, Livestreams und veröffentlichten Chart-Analysen.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © Trading Strategen & Velgo.ai

//@version=6
indicator("TS × Velgo Watermark", overlay = true)

pos_s       = input.string("Unten Mitte", "Position",
              options = ["Oben Links","Oben Mitte","Oben Rechts",
                         "Mitte Links","Mitte","Mitte Rechts",
                         "Unten Links","Unten Mitte","Unten Rechts"])
transp      = input.int(75, "Transparenz %", minval = 0, maxval = 100)
title_size  = input.string("large", "Schriftgröße Titel",       options = ["tiny","small","normal","large","huge"])
sub_size    = input.string("small", "Schriftgröße Untertitel",   options = ["tiny","small","normal","large","huge"])
line1_text  = input.string("TRADING STRATEGEN",                      "Zeile 1 Text")
line1_color = input.color(color.rgb(180, 155, 90),                   "Zeile 1 Farbe")
line2_text  = input.string("DISZIPLIN  |  GEDULD  |  VERANTWORTUNG", "Zeile 2 Text")
line2_color = input.color(color.gray,                                 "Zeile 2 Farbe")
line3_text  = input.string("VELGO.AI",                               "Zeile 3 Text")
line3_color = input.color(color.gray,                                 "Zeile 3 Farbe")
show_bg     = input.bool(false,                                       "Hintergrund anzeigen")
bg_color    = input.color(color.new(color.black, 80),                 "Hintergrundfarbe")

f_pos(string s) =>
    switch s
        "Oben Links"   => position.top_left
        "Oben Mitte"   => position.top_center
        "Oben Rechts"  => position.top_right
        "Mitte Links"  => position.middle_left
        "Mitte"        => position.middle_center
        "Mitte Rechts" => position.middle_right
        "Unten Links"  => position.bottom_left
        "Unten Rechts" => position.bottom_right
        =>               position.bottom_center

f_size(string s) =>
    switch s
        "tiny"  => size.tiny
        "small" => size.small
        "large" => size.large
        "huge"  => size.huge
        =>         size.normal

c_none = color.new(color.white, 100)
c_bg   = show_bg ? bg_color : c_none

var table t = table.new(f_pos(pos_s), 1, 3, border_width = 0, frame_width = 0)

if barstate.islast
    table.cell(t, 0, 0, line1_text,
         text_color = color.new(line1_color, transp),
         text_size = f_size(title_size), text_halign = text.align_center, bgcolor = c_bg)
    table.cell(t, 0, 1, line2_text,
         text_color = color.new(line2_color, transp),
         text_size = f_size(sub_size), text_halign = text.align_center, bgcolor = c_bg)
    table.cell(t, 0, 2, line3_text,
         text_color = color.new(line3_color, transp),
         text_size = f_size(sub_size), text_halign = text.align_center, bgcolor = c_bg)
````
