# EMA Trend Stack 9  21  50 200

- url: https://www.tradingview.com/script/aZ5EjEo7-EMA-Trend-Stack-9-21-50-200/
- type: indicator
- pine_id: PUB;7a144525b5ce4f3083a16f2e484c1501
- version: 1.0

## Description

EMA 9/21/50/200 lines
Zones for momentum indicators, 50/200 crossover indicated as momentum switch

## Source Code

````pine
//@version=6
// EMA Trend Stack — plots the 9 / 21 / 50 / 200 EMAs and reads the trend
// state from how they're stacked and where the key pairs cross.
indicator("EMA Trend Stack — 9 / 21 / 50 / 200", shorttitle="EMA Trend", overlay=true)

// ============================== INPUTS ==============================
src = input.source(close, "Source", group="Source")

grpL = "EMA Lengths"
len1 = input.int(9,   "EMA 1 (Fast)", minval=1, group=grpL)
len2 = input.int(21,  "EMA 2",        minval=1, group=grpL)
len3 = input.int(50,  "EMA 3",        minval=1, group=grpL)
len4 = input.int(200, "EMA 4 (Slow)", minval=1, group=grpL)

grpV = "Visibility"
show1 = input.bool(true, "Show EMA 1 (9)",   group=grpV)
show2 = input.bool(true, "Show EMA 2 (21)",  group=grpV)
show3 = input.bool(true, "Show EMA 3 (50)",  group=grpV)
show4 = input.bool(true, "Show EMA 4 (200)", group=grpV)

grpE = "Trend Extras"
showCloud = input.bool(true, "Fast cloud (EMA1–EMA2)",           group=grpE)
showCross = input.bool(true, "Golden / Death cross (EMA3×EMA4)", group=grpE)
showStack = input.bool(true, "Trend-stack label",                group=grpE)

// =========================== CALCULATIONS ===========================
ema1 = ta.ema(src, len1)
ema2 = ta.ema(src, len2)
ema3 = ta.ema(src, len3)
ema4 = ta.ema(src, len4)

// ============================== PLOTS ===============================
// Warm (fast) -> cool (slow) gradient so the eye reads EMA speed instantly.
p1 = plot(show1 ? ema1 : na, "EMA 1", color=color.new(#ff5252, 0), linewidth=2)
p2 = plot(show2 ? ema2 : na, "EMA 2", color=color.new(#ffb74d, 0), linewidth=2)
p3 = plot(show3 ? ema3 : na, "EMA 3", color=color.new(#42a5f5, 0), linewidth=2)
p4 = plot(show4 ? ema4 : na, "EMA 4", color=color.new(#7e57c2, 0), linewidth=3)

// Fast cloud: shaded green when EMA1 >= EMA2, red otherwise — a glanceable
// read of short-term momentum direction without staring at line crossings.
cloudCol = ema1 >= ema2 ? color.new(color.green, 85) : color.new(color.red, 85)
fill(p1, p2, color = showCloud ? cloudCol : na, title="Fast Cloud")

// Golden / Death cross on the 50/200 — the classic regime-change signal.
golden = ta.crossover(ema3, ema4)
death  = ta.crossunder(ema3, ema4)
plotshape(showCross and golden ? ema4 : na, title="Golden Cross",
     style=shape.triangleup,   location=location.absolute,
     color=color.new(color.green, 0), size=size.small, text="Golden")
plotshape(showCross and death ? ema4 : na, title="Death Cross",
     style=shape.triangledown, location=location.absolute,
     color=color.new(color.red, 0),   size=size.small, text="Death")

// Trend stack: when EMAs line up 9>21>50>200 the trend is "fully stacked"
// — the strongest, cleanest trend condition. Mixed = chop / transition.
bullStack = ema1 > ema2 and ema2 > ema3 and ema3 > ema4
bearStack = ema1 < ema2 and ema2 < ema3 and ema3 < ema4
stackTxt  = bullStack ? "▲ Full Bull Stack" : bearStack ? "▼ Full Bear Stack" : "↔ Mixed / Transition"
stackCol  = bullStack ? color.green : bearStack ? color.red : color.gray

var label stackLbl = na
if showStack and barstate.islast
    label.delete(stackLbl)
    stackLbl := label.new(bar_index, ema1, stackTxt,
         style=label.style_label_left, color=color.new(stackCol, 20),
         textcolor=color.white, size=size.normal)

// ============================== ALERTS ==============================
alertcondition(golden, "Golden Cross (50/200)", "EMA50 crossed above EMA200")
alertcondition(death,  "Death Cross (50/200)",  "EMA50 crossed below EMA200")
````
