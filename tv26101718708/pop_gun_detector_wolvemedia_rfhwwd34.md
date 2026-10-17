# Pop Gun Detector Wolvemedia

- url: https://www.tradingview.com/script/rFHwWD34/
- type: indicator
- pine_id: PUB;691474612bb94e63bc4075ea854ff938
- version: 1.0

## Description

Detector for Pop Gun Trading. Identifying and marking patternin chart. Shows you take profit and activation zones.

For personal trading and on your owns risk pls.

## Source Code

````pine
//@version=5
indicator("🔫 Pop Gun Detector", overlay=true, max_boxes_count=200, max_lines_count=400, max_labels_count=200)

// ══════════════════════════════════════════════
//  INPUTS
// ══════════════════════════════════════════════
showBull   = input.bool(true,  "Bullish Signale anzeigen",  group="Anzeige")
showBear   = input.bool(true,  "Bearish Signale anzeigen",  group="Anzeige")
showTP     = input.bool(true,  "TP-Levels anzeigen",        group="Anzeige")
showBox    = input.bool(true,  "Box um alle 3 Kerzen anzeigen", group="Anzeige")
tpLen      = input.int(20,     "TP-Linien Länge (Bars)",    group="Anzeige", minval=5, maxval=100)

// ══════════════════════════════════════════════
//  POP GUN LOGIK
//  C1 = bar[2], C2 = bar[1], C3 = bar[0]
//  Regel: C1 umschließt C2 vollständig
//         C3 umschließt C2 vollständig
// ══════════════════════════════════════════════
c1_hi  = high[2]
c1_lo  = low[2]
c1_len = c1_hi - c1_lo

c2_hi  = high[1]
c2_lo  = low[1]

c3_hi  = high
c3_lo  = low

c1_engulfs_c2 = c1_hi > c2_hi and c1_lo < c2_lo
c3_engulfs_c2 = c3_hi > c2_hi and c3_lo < c2_lo

// Muster erkannt (ohne Ausbruchsbedingung)
popgun = c1_engulfs_c2 and c3_engulfs_c2

// ── Ausbruch-Richtung ──────────────────────────
bull_break = popgun and close > c1_hi  // Schlusskurs über Hoch C1
bear_break = popgun and close < c1_lo  // Schlusskurs unter Tief C1
neutral    = popgun and not bull_break and not bear_break

// ══════════════════════════════════════════════
//  TP-BERECHNUNG — ab Hoch/Tief von Kerze 1 (C1)
//  Bull: ab c1_hi | Bear: ab c1_lo
//  TP1 = 1× C1-Länge | TP2 = 2× C1-Länge
// ══════════════════════════════════════════════
bull_act = c1_hi  // Aktivierungslevel Long = Hoch C1
bear_act = c1_lo  // Aktivierungslevel Short = Tief C1

bull_tp1 = c1_hi + c1_len
bull_tp2 = c1_hi + 2 * c1_len
bear_tp1 = c1_lo - c1_len
bear_tp2 = c1_lo - 2 * c1_len

// ══════════════════════════════════════════════
//  BOX UM ALLE 3 KERZEN (C1 + C2 + C3)
//  Gold = Setup (kein Ausbruch)  |  Grün = bullish  |  Orange = bearish
// ══════════════════════════════════════════════
box_hi = math.max(c1_hi, c2_hi, c3_hi)
box_lo = math.min(c1_lo, c2_lo, c3_lo)

var color BOX_CLR_NEUT = color.new(color.yellow, 80)
var color BOX_CLR_BULL = color.new(color.green,  80)
var color BOX_CLR_BEAR = color.new(color.orange, 80)

if popgun and showBox
    color boxBorder = bull_break ? color.green : bear_break ? color.orange : color.yellow
    color boxBg = bull_break ? BOX_CLR_BULL : bear_break ? BOX_CLR_BEAR : BOX_CLR_NEUT
    box.new(bar_index - 2, box_hi, bar_index, box_lo, border_color=boxBorder, border_width=3, bgcolor=boxBg)

// ── Kerzen einfärben: C1 + C3 = gold, C2 = blau (innere Kerze) ──
barcolor(popgun ? color.new(#FFD700, 20) : na, offset=-2, title="C1 Highlight")
barcolor(popgun ? color.new(color.blue, 30) : na, offset=-1, title="C2 Highlight")
barcolor(popgun ? color.new(#FFD700, 20) : na, offset=0,  title="C3 Highlight")

// ══════════════════════════════════════════════
//  DEDUP — jedes Muster nur einmal zeichnen
//  Verhindert überlappende Lines von mehreren C1-Bars
// ══════════════════════════════════════════════
var int last_bull_idx = na
var int last_bear_idx = na
var int last_neut_idx = na

new_bull = bull_break and (na(last_bull_idx) or bar_index - last_bull_idx > 3)
new_bear = bear_break and (na(last_bear_idx) or bar_index - last_bear_idx > 3)
new_neut = neutral    and (na(last_neut_idx) or bar_index - last_neut_idx > 3)

if new_bull
    last_bull_idx := bar_index

if new_bear
    last_bear_idx := bar_index

if new_neut
    last_neut_idx := bar_index

// ══════════════════════════════════════════════
//  TP-LINIEN + LABELS
// ══════════════════════════════════════════════
if new_bull and showBull and showTP
    line.new(bar_index - 2, bull_act, bar_index + tpLen, bull_act, color=color.green,  width=2, style=line.style_solid)
    line.new(bar_index - 2, bull_tp1, bar_index + tpLen, bull_tp1, color=color.blue,   width=2, style=line.style_dashed)
    line.new(bar_index - 2, bull_tp2, bar_index + tpLen, bull_tp2, color=color.purple, width=2, style=line.style_dashed)
    label.new(bar_index + tpLen, bull_act, " Aktivierung " + str.tostring(bull_act, format.mintick), color=color.green,  textcolor=color.white, style=label.style_label_left, size=size.small)
    label.new(bar_index + tpLen, bull_tp1, " TP1  "        + str.tostring(bull_tp1, format.mintick), color=color.blue,   textcolor=color.white, style=label.style_label_left, size=size.small)
    label.new(bar_index + tpLen, bull_tp2, " TP2  "        + str.tostring(bull_tp2, format.mintick), color=color.purple, textcolor=color.white, style=label.style_label_left, size=size.small)

if new_bear and showBear and showTP
    line.new(bar_index - 2, bear_act, bar_index + tpLen, bear_act, color=color.red,    width=2, style=line.style_solid)
    line.new(bar_index - 2, bear_tp1, bar_index + tpLen, bear_tp1, color=color.blue,   width=2, style=line.style_dashed)
    line.new(bar_index - 2, bear_tp2, bar_index + tpLen, bear_tp2, color=color.purple, width=2, style=line.style_dashed)
    label.new(bar_index + tpLen, bear_act, " Aktivierung " + str.tostring(bear_act, format.mintick), color=color.red,    textcolor=color.white, style=label.style_label_left, size=size.small)
    label.new(bar_index + tpLen, bear_tp1, " TP1  "        + str.tostring(bear_tp1, format.mintick), color=color.blue,   textcolor=color.white, style=label.style_label_left, size=size.small)
    label.new(bar_index + tpLen, bear_tp2, " TP2  "        + str.tostring(bear_tp2, format.mintick), color=color.purple, textcolor=color.white, style=label.style_label_left, size=size.small)

// ══════════════════════════════════════════════
//  SIGNAL-LABEL AM CHART
// ══════════════════════════════════════════════
if new_bull and showBull
    label.new(bar_index, low, "🔫 BULL", color=color.green, textcolor=color.white, style=label.style_label_up, size=size.small)

if new_bear and showBear
    label.new(bar_index, high, "🔫 BEAR", color=color.red, textcolor=color.white, style=label.style_label_down, size=size.small)

if new_neut
    label.new(bar_index, high, "⭐",
              color=color.new(#FFD700, 10), textcolor=color.new(#FFD700, 0),
              style=label.style_label_down, size=size.large)
    if showTP
        line.new(bar_index - 2, c1_hi,    bar_index + tpLen, c1_hi,    color=color.green,  width=2, style=line.style_solid)
        line.new(bar_index - 2, c1_lo,    bar_index + tpLen, c1_lo,    color=color.red,    width=2, style=line.style_solid)
        line.new(bar_index - 2, bull_tp1, bar_index + tpLen, bull_tp1, color=color.blue,   width=2, style=line.style_dashed)
        line.new(bar_index - 2, bull_tp2, bar_index + tpLen, bull_tp2, color=color.purple, width=2, style=line.style_dashed)
        line.new(bar_index - 2, bear_tp1, bar_index + tpLen, bear_tp1, color=color.blue,   width=2, style=line.style_dashed)
        line.new(bar_index - 2, bear_tp2, bar_index + tpLen, bear_tp2, color=color.purple, width=2, style=line.style_dashed)
        label.new(bar_index + tpLen, c1_hi,    " Aktivierung " + str.tostring(c1_hi,    format.mintick), color=color.green,  textcolor=color.white, style=label.style_label_left, size=size.small)
        label.new(bar_index + tpLen, c1_lo,    " Aktivierung " + str.tostring(c1_lo,    format.mintick), color=color.red,    textcolor=color.white, style=label.style_label_left, size=size.small)
        label.new(bar_index + tpLen, bull_tp1, " TP1  "        + str.tostring(bull_tp1, format.mintick), color=color.blue,   textcolor=color.white, style=label.style_label_left, size=size.small)
        label.new(bar_index + tpLen, bull_tp2, " TP2  "        + str.tostring(bull_tp2, format.mintick), color=color.purple, textcolor=color.white, style=label.style_label_left, size=size.small)
        label.new(bar_index + tpLen, bear_tp1, " TP1  "        + str.tostring(bear_tp1, format.mintick), color=color.blue,   textcolor=color.white, style=label.style_label_left, size=size.small)
        label.new(bar_index + tpLen, bear_tp2, " TP2  "        + str.tostring(bear_tp2, format.mintick), color=color.purple, textcolor=color.white, style=label.style_label_left, size=size.small)

// ══════════════════════════════════════════════
//  HINTERGRUNDFARBE BEI AUSBRUCH
// ══════════════════════════════════════════════
bgcolor(bull_break and showBull ? color.new(color.green, 92) : na)
bgcolor(bear_break and showBear ? color.new(color.red,   92) : na)

// ══════════════════════════════════════════════
//  ALERTS
// ══════════════════════════════════════════════
alertcondition(bull_break, "🔫 Pop Gun BULLISH", "Pop Gun: Bullischer Ausbruch über C1-Hoch! TP1={{plot_0}} TP2={{plot_1}}")
alertcondition(bear_break, "🔫 Pop Gun BEARISH", "Pop Gun: Bärischer Ausbruch unter C1-Tief!")
alertcondition(neutral,    "🔫 Pop Gun Setup",   "Pop Gun: Muster erkannt, kein Ausbruch noch.")

// Unsichtbare Plots für Alert-Variablen
plot(bull_break ? bull_tp1 : na, display=display.none, title="Bull TP1")
plot(bull_break ? bull_tp2 : na, display=display.none, title="Bull TP2")
plot(bear_break ? bear_tp1 : na, display=display.none, title="Bear TP1")
plot(bear_break ? bear_tp2 : na, display=display.none, title="Bear TP2")
````
