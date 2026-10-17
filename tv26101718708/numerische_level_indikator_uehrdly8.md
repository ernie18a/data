# Numerische Level Indikator

- url: https://www.tradingview.com/script/ueHRdlY8/
- type: indicator
- pine_id: PUB;087587b7362d4cda9352d23770ca6ae4
- version: 1.0

## Description

Es werden im Markt alle Numerischen Lvl mit einer Gepunkteten Linie Makiert.
Timeframe ist dabei egal

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MNeuber

//@version=5
indicator("Numerische Level Indikator", overlay=true, max_lines_count=500)

// --- Inputs ---
step = input.float(50.0, "Intervall (z.B. 50 oder 100)", minval=0.1)
num_levels = input.int(10, "Anzahl Level (nach oben/unten)", minval=1)
line_color = input.color(color.new(color.gray, 50), "Linienfarbe")
line_style = input.string("Gepunktet", "Linienstil", options=["Durchgehend", "Gepunktet", "Gestrichelt"])
show_labels = input.bool(true, "Preise anzeigen?")

// Umwandlung des Linienstils
style_type = line_style == "Durchgehend" ? line.style_solid : 
             line_style == "Gestrichelt" ? line.style_dashed : 
             line.style_dotted

// --- Logik ---
// Wir berechnen das Start-Level basierend auf dem aktuellen Preis
var line[] lines = array.new_line()
var label[] labels = array.new_label()

// Da wir Linien zeichnen, löschen wir die alten beim neuen Balken (effizienter für den Chart)
if barstate.islast
    // Alte Zeichnungen entfernen
    for l in lines
        line.delete(l)
    for lb in labels
        label.delete(lb)
    
    array.clear(lines)
    array.clear(labels)

    // Berechne die Basis (nächste abgerundete Zahl)
    float pivot = math.round(close / step) * step

    // Zeichne Level über und unter dem Preis
    for i = -num_levels to num_levels
        float level_price = pivot + (i * step)
        
        // Linie erstellen
        line l = line.new(
             x1=bar_index - 100, 
             y1=level_price, 
             x2=bar_index + 10, 
             y2=level_price, 
             width=1, 
             color=line_color, 
             style=style_type, 
             extend=extend.both
             )
        array.push(lines, l)

        // Label (Preis) erstellen
        if show_labels
            label lb = label.new(
                 x=bar_index + 5, 
                 y=level_price, 
                 text=str.tostring(level_price), 
                 style=label.style_none, 
                 textcolor=line_color, 
                 size=size.small
                 )
            array.push(labels, lb)
````
