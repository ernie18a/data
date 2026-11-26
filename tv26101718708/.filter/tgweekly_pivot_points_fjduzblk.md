# TG_Weekly Pivot Points

- url: https://www.tradingview.com/script/FjduzbLK/
- type: indicator
- pine_id: PUB;bce28cc3005b4d8b868def01056f813b
- version: 1.0

## Description

Weekly Pivotlinien sind eleganter als Weekly High und Weekly Low, da der Weekly Close noch mit eingerechnet wird. Ist der Trader in kleineren Zeiteinheiten, ist die Wocheneinstellung immer zu sehen und gibt Orientierung in welchem "Zoom" er sich gerade befindet.

Ich habe nur Weekly Pivot und R1 und S1 eingeblendet, um einen Rahmen zu haben, wie die Woche und die vergangenen Wochen sich verhalten haben.
Gruß TG

## Source Code

````pine
// © Grok + gottinord_trading – Standalone Weekly Pivot Points
//@version=6
indicator("TG_Weekly Pivot Points", shorttitle="TG_Pivots", overlay=true, max_lines_count=500, max_labels_count=500)

// ────────────────────────────────────────────────
// Eingaben
// ────────────────────────────────────────────────
showPivots        = input.bool(true,  "Weekly Pivot Points anzeigen", group="Sichtbarkeit")

showPP            = input.bool(true,  "Pivot Point (PP) anzeigen", group="Levels")
showR1            = input.bool(true,  "R1 anzeigen", group="Levels")
showR2            = input.bool(true,  "R2 anzeigen", group="Levels")
showR3            = input.bool(true,  "R3 anzeigen", group="Levels")
showS1            = input.bool(true,  "S1 anzeigen", group="Levels")
showS2            = input.bool(true,  "S2 anzeigen", group="Levels")
showS3            = input.bool(true,  "S3 anzeigen", group="Levels")

pivotLineWidth    = input.int(2, "Linienstärke", minval=1, maxval=4, group="Stil")
pivotLineStyleStr = input.string("Solid", "Linienstil", options=["Solid", "Dashed", "Dotted"], group="Stil")

ppColor = input.color(color.new(color.blue, 0),   "Farbe PP",  group="Farben")
r1Color = input.color(color.new(color.green, 20), "Farbe R1",  group="Farben")
r2Color = input.color(color.new(color.green, 40), "Farbe R2",  group="Farben")
r3Color = input.color(color.new(color.green, 60), "Farbe R3",  group="Farben")
s1Color = input.color(color.new(color.red, 20),   "Farbe S1",  group="Farben")
s2Color = input.color(color.new(color.red, 40),   "Farbe S2",  group="Farben")
s3Color = input.color(color.new(color.red, 60),   "Farbe S3",  group="Farben")

// Linienstil
pivotStyle = pivotLineStyleStr == "Solid" ? plot.style_line : 
             pivotLineStyleStr == "Dashed" ? plot.style_line : plot.style_line

// ────────────────────────────────────────────────
// Weekly OHLC der vorherigen abgeschlossenen Woche
// ────────────────────────────────────────────────
[weeklyH, weeklyL, weeklyC] = request.security(syminfo.tickerid, "W", [high[1], low[1], close[1]], lookahead=barmerge.lookahead_on)

// ────────────────────────────────────────────────
// Klassische Weekly Pivot Points berechnen
// ────────────────────────────────────────────────
pp = (weeklyH + weeklyL + weeklyC) / 3
r1 = (pp * 2) - weeklyL
s1 = (pp * 2) - weeklyH
r2 = pp + (weeklyH - weeklyL)
s2 = pp - (weeklyH - weeklyL)
r3 = weeklyH + 2 * (pp - weeklyL)
s3 = weeklyL - 2 * (weeklyH - pp)

// ────────────────────────────────────────────────
// Plots
// ────────────────────────────────────────────────
plot(showPivots and showPP ? pp : na, "Weekly PP", color=ppColor, linewidth=pivotLineWidth, style=pivotStyle)
plot(showPivots and showR1 ? r1 : na, "Weekly R1", color=r1Color, linewidth=pivotLineWidth, style=pivotStyle)
plot(showPivots and showR2 ? r2 : na, "Weekly R2", color=r2Color, linewidth=pivotLineWidth, style=pivotStyle)
plot(showPivots and showR3 ? r3 : na, "Weekly R3", color=r3Color, linewidth=pivotLineWidth, style=pivotStyle)
plot(showPivots and showS1 ? s1 : na, "Weekly S1", color=s1Color, linewidth=pivotLineWidth, style=pivotStyle)
plot(showPivots and showS2 ? s2 : na, "Weekly S2", color=s2Color, linewidth=pivotLineWidth, style=pivotStyle)
plot(showPivots and showS3 ? s3 : na, "Weekly S3", color=s3Color, linewidth=pivotLineWidth, style=pivotStyle)

// ────────────────────────────────────────────────
// Labels nur beim Wochenwechsel
// ────────────────────────────────────────────────
newWeek = ta.change(time("W")) != 0

if showPivots and newWeek
    if showPP
        label.new(bar_index, pp, "PP", yloc=yloc.price, color=color.new(color.blue, 70), style=label.style_label_left, size=size.tiny, textcolor=color.white)
    if showR1
        label.new(bar_index, r1, "R1", yloc=yloc.price, color=color.new(color.green, 70), style=label.style_label_left, size=size.tiny, textcolor=color.white)
    if showS1
        label.new(bar_index, s1, "S1", yloc=yloc.price, color=color.new(color.red, 70), style=label.style_label_left, size=size.tiny, textcolor=color.white)
    if showR2
        label.new(bar_index, r2, "R2", yloc=yloc.price, color=color.new(color.green, 70), style=label.style_label_left, size=size.tiny, textcolor=color.white)
    if showS2
        label.new(bar_index, s2, "S2", yloc=yloc.price, color=color.new(color.red, 70), style=label.style_label_left, size=size.tiny, textcolor=color.white)
    if showR3
        label.new(bar_index, r3, "R3", yloc=yloc.price, color=color.new(color.green, 70), style=label.style_label_left, size=size.tiny, textcolor=color.white)
    if showS3
        label.new(bar_index, s3, "S3", yloc=yloc.price, color=color.new(color.red, 70), style=label.style_label_left, size=size.tiny, textcolor=color.white)
````
