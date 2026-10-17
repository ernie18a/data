# SMMA Trio mit Labels (50, 100, 200)

- url: https://www.tradingview.com/script/vJxycifv/
- type: indicator
- pine_id: PUB;38897c70f39a4aa7ab4363affa177296
- version: 1.0

## Description

3 SMMA Durchschnittslinien mit Labels
- SMMA 50
- SMMA 100
- SMMA 200

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © DonPedro_

//@version=6
indicator(title="SMMA Trio mit Labels (50, 100, 200)", shorttitle="SMMA 50/100/200 + Labels", overlay=true)

// --- Inputs ---
src = input.source(close, title="Quelle")
len1 = input.int(50, minval=1, title="SMMA 1 Länge")
len2 = input.int(100, minval=1, title="SMMA 2 Länge")
len3 = input.int(200, minval=1, title="SMMA 3 Länge")

// --- Custom SMMA Funktion ---
smma(source, length) =>
    emaLength = (length * 2) - 1
    ta.ema(source, emaLength)

// --- Berechnung ---
smma50  = smma(src, len1)
smma100 = smma(src, len2)
smma200 = smma(src, len3)

// --- Plotting der Linien ---
plot(smma50,  color=color.blue,  title="SMMA 50",  linewidth=2)
plot(smma100, color=color.orange, title="SMMA 100", linewidth=2)
plot(smma200, color=color.red,    title="SMMA 200", linewidth=2)

// --- Funktion für die Labels am Linienende ---
f_draw_label(x_pos, y_pos, label_text, label_color) =>
    var label lbl = na
    if barstate.islast
        if not na(lbl)
            label.delete(lbl)
        lbl := label.new(
             x=x_pos, 
             y=y_pos, 
             text=label_text, 
             textcolor=label_color, 
             color=color.new(color.white, 100), // 100% transparent (kein Hintergrund)
             style=label.style_label_left, 
             yloc=yloc.price
             )

// --- Labels zeichnen (wird nur auf der allerletzten Kerze ausgeführt)
f_draw_label(bar_index + 2, smma50,  "SMMA 50",  color.blue)
f_draw_label(bar_index + 2, smma100, "SMMA 100", color.orange)
f_draw_label(bar_index + 2, smma200, "SMMA 200", color.red)
````
