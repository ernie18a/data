# EMA Ribbon [Proozac]

- url: https://www.tradingview.com/script/tXGUtneN-EMA-Ribbon-Proozac/
- type: indicator
- pine_id: PUB;c36cf09807764935b3ae7a713d3a1d13
- version: 1.0

## Description

A 5-period EMA ribbon designed for fast visual trend identification, with end-of-line labels so each moving average is instantly recognizable without hovering over the chart.
How it works
Plots five exponential moving averages (9, 15, 30, 65, 200 by default) color-coded for quick reference. When all 5 EMAs align in perfect ascending or descending order, the chart background shades green or red to confirm a clean trend structure — the same "ribbon alignment" signal experienced traders use to filter entries.

Cyan — EMA 9 (fastest)
Orange — EMA 15
Green — EMA 30
Yellow — EMA 65
White — EMA 200 (slowest)

Right-edge labels
Each EMA line has a label pinned to the current price level on the right edge of the chart, color-matched to its line. Labels move dynamically with both horizontal scroll and vertical price scaling, so you always know which line is which at a glance.
Crossover signals
Triangle markers flag crossovers between the fast (EMA 9) and mid (EMA 30) average — the most relevant short-term trend shift in the ribbon.
Background shading

🟢 Green tint — all 5 EMAs in bullish order (9 > 15 > 30 > 65 > 200)
🔴 Red tint — all 5 EMAs in bearish order (9 < 15 < 30 < 65 < 200)

Configurable parameters

All 5 EMA periods individually adjustable
Fully customizable colors
Toggle right-edge labels on/off
Alerts for EMA 9/30 crossovers and full ribbon alignment

Recommended use
Built for intraday trend-following setups on indices and futures, particularly effective alongside VWAP and volume-based confirmation tools.

## Source Code

````pine
//@version=6
indicator(title="EMA Ribbon [Proozac]", shorttitle="EMA Ribbon", overlay=true)

// ─────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────
grp1 = "EMA Periods"
p1 = input.int(9,   "EMA 1 (más rápida)", minval=1, group=grp1)
p2 = input.int(15,  "EMA 2",              minval=1, group=grp1)
p3 = input.int(30,  "EMA 3",              minval=1, group=grp1)
p4 = input.int(65,  "EMA 4",              minval=1, group=grp1)
p5 = input.int(200, "EMA 5 (más lenta)",  minval=1, group=grp1)

grp2 = "Colores"
c1 = input.color(color.new(#00BCD4, 0),  "EMA 9   — Cyan",    group=grp2)
c2 = input.color(color.new(#FF9800, 0),  "EMA 15  — Naranja", group=grp2)
c3 = input.color(color.new(#8BC34A, 0),  "EMA 30  — Verde",   group=grp2)
c4 = input.color(color.new(#FFD600, 0),  "EMA 65  — Amarilla",group=grp2)
c5 = input.color(color.new(#FFFFFF, 0),  "EMA 200 — Blanca",  group=grp2)

grp3 = "Labels"
show_labels = input.bool(true, "Mostrar labels al borde derecho", group=grp3)

// ─────────────────────────────────────────────
//  CÁLCULO DE EMAs
// ─────────────────────────────────────────────
e1 = ta.ema(close, p1)
e2 = ta.ema(close, p2)
e3 = ta.ema(close, p3)
e4 = ta.ema(close, p4)
e5 = ta.ema(close, p5)

// ─────────────────────────────────────────────
//  PLOTS
// ─────────────────────────────────────────────
plot(e1, "EMA 9",   color=c1, linewidth=1)
plot(e2, "EMA 15",  color=c2, linewidth=1)
plot(e3, "EMA 30",  color=c3, linewidth=2)
plot(e4, "EMA 65",  color=c4, linewidth=2)
plot(e5, "EMA 200", color=c5, linewidth=2)

// ─────────────────────────────────────────────
//  ORDEN DEL RIBBON
// ─────────────────────────────────────────────
ribbon_bull = e1 > e2 and e2 > e3 and e3 > e4 and e4 > e5
ribbon_bear = e1 < e2 and e2 < e3 and e3 < e4 and e4 < e5

bgcolor(ribbon_bull ? color.new(color.green, 93) : na, title="Ribbon alcista")
bgcolor(ribbon_bear ? color.new(color.red,   93) : na, title="Ribbon bajista")

// ─────────────────────────────────────────────
//  CRUCES EMA 9 / EMA 30
// ─────────────────────────────────────────────
cross_bull = ta.crossover(e1, e3)
cross_bear = ta.crossunder(e1, e3)

plotshape(cross_bull, title="Cruce alcista 9/30", location=location.belowbar,
     style=shape.triangleup,   size=size.tiny, color=color.new(color.lime, 20))
plotshape(cross_bear, title="Cruce bajista 9/30", location=location.abovebar,
     style=shape.triangledown, size=size.tiny, color=color.new(color.red,  20))

// ─────────────────────────────────────────────
//  ALERTAS — scope global
// ─────────────────────────────────────────────
alertcondition(cross_bull,                         "EMA 9 cruza arriba EMA 30", "Cruce alcista — EMA 9 > EMA 30")
alertcondition(cross_bear,                         "EMA 9 cruza abajo EMA 30",  "Cruce bajista — EMA 9 < EMA 30")
alertcondition(ribbon_bull and not ribbon_bull[1], "Ribbon alcista completo",   "Las 5 EMAs en orden alcista perfecto")
alertcondition(ribbon_bear and not ribbon_bear[1], "Ribbon bajista completo",   "Las 5 EMAs en orden bajista perfecto")

// ─────────────────────────────────────────────
//  LABELS AL BORDE DERECHO
//  Se usan label.set_* para mover el label existente
//  en cada tick — así siguen al precio al hacer scroll
// ─────────────────────────────────────────────
var label lbl1 = label.new(bar_index, e1, "EMA 9",
     style=label.style_label_left, color=color.new(c1, 75),
     textcolor=c1, size=size.small)

var label lbl2 = label.new(bar_index, e2, "EMA 15",
     style=label.style_label_left, color=color.new(c2, 75),
     textcolor=c2, size=size.small)

var label lbl3 = label.new(bar_index, e3, "EMA 30",
     style=label.style_label_left, color=color.new(c3, 75),
     textcolor=c3, size=size.small)

var label lbl4 = label.new(bar_index, e4, "EMA 65",
     style=label.style_label_left, color=color.new(c4, 75),
     textcolor=c4, size=size.small)

var label lbl5 = label.new(bar_index, e5, "EMA 200",
     style=label.style_label_left, color=color.new(c5, 75),
     textcolor=c5, size=size.small)

if show_labels
    label.set_xy(lbl1, bar_index + 1, e1)
    label.set_xy(lbl2, bar_index + 1, e2)
    label.set_xy(lbl3, bar_index + 1, e3)
    label.set_xy(lbl4, bar_index + 1, e4)
    label.set_xy(lbl5, bar_index + 1, e5)
else
    label.set_xy(lbl1, bar_index + 1, na)
    label.set_xy(lbl2, bar_index + 1, na)
    label.set_xy(lbl3, bar_index + 1, na)
    label.set_xy(lbl4, bar_index + 1, na)
    label.set_xy(lbl5, bar_index + 1, na)
````
