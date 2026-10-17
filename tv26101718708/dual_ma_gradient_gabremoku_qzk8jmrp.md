# Dual MA Gradient [Gabremoku]

- url: https://www.tradingview.com/script/qzk8JMRP-Dual-MA-Gradient-Gabremoku/
- type: indicator
- pine_id: PUB;5e090ee71d7149949059de37e01eb61d
- version: 1.0

## Description

Dual MA Gradient [Gabremoku] is a clean dual moving average overlay designed to highlight not only MA direction and crossover, but also the degree of separation between the two averages through a dynamic gradient ribbon.

The script uses two configurable moving averages and transforms their relationship into a visual ribbon that reacts to:

bullish alignment

bearish alignment

neutral compression

Instead of relying only on a simple crossover, the indicator helps show whether the two averages are:

crossing,

compressing,

or expanding apart

That makes it useful as a compact trend-structure tool for traders who want an at-a-glance read on direction and relative momentum.

What it shows
📈 Two configurable moving averages — each MA can be set independently using:

EMA or SMA

custom length

custom source

🌈 Directional gradient ribbon — the space between the two averages is divided into layered fills that create a smooth visual ribbon.

🟦 Bullish separation — when the fast MA is above the slow MA, the ribbon shifts to bullish color.

🟨 Bearish separation — when the fast MA is below the slow MA, the ribbon shifts to bearish color.

⚪ Compression state — when the spread between the two MAs becomes small enough, the ribbon fades into a neutral state to signal contraction.

🏷️ Status label — optional live label shows the active state:

Compression

Bullish Separation

Bearish Separation

⭕ Cross markers — optional markers can be shown when bullish or bearish MA crosses occur.

Core logic
The indicator is built around three simple but useful ideas:

Which MA is on top

How far apart the two MAs are

Whether the spread is strong enough to be directional or too tight and neutral

A moving average crossover occurs when a shorter-period average crosses a longer-period average, and it is commonly used to identify trend shifts or signal changes in directional bias.

This script goes a step further by emphasizing the spread between the averages. That matters because ribbon spacing is often used as a visual clue for trend structure: when averages are compressed, the market may be in transition or contraction, while a wider directional ribbon can reflect stronger alignment.

How to read it
A practical reading method is:

Compression = the two averages are close together, market may be transitioning or losing directional clarity

Bullish separation = the fast MA is above the slow MA and the ribbon is opening upward

Bearish separation = the fast MA is below the slow MA and the ribbon is opening downward

In many moving-average frameworks:

the cross helps identify the directional shift

the spacing helps evaluate whether that shift is weak or established

a tight ribbon often suggests indecision or a developing transition

Features
✅ Dual moving average framework

✅ SMA or EMA selection for both lines

✅ Fully customizable lengths

✅ Dynamic layered ribbon between MAs

✅ Bullish / bearish / neutral compression states

✅ Optional MA line display

✅ Optional live status label

✅ Optional crossover markers

✅ Built-in bullish and bearish crossover alerts

Notes
This indicator is designed as a trend-visualization tool rather than a complete standalone strategy. Like all moving-average systems, it is inherently lagging, so it is generally more useful for confirming structure and directional bias than for predicting reversals in isolation.

Author: Gabremoku
Pine Script v6

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Gabremoku

//@version=6
indicator(title = "Dual MA Gradient [Gabremoku]",
     overlay = true,
     max_labels_count = 500,
     max_lines_count = 500)

// ═══════════════════════════════════════════════════════════════
// Dual MA Gradient [Gabremoku]
// Two moving averages with directional gradient ribbon
// Bull = Blue | Bear = Yellow
// ═══════════════════════════════════════════════════════════════

// ── INPUTS ─────────────────────────────────────────────────────
grp3 = "Display"
showMAs        = input.bool(false, "Show MA Lines", group = grp3)
showLabel      = input.bool(true, "Show Status Label", group = grp3)
showCrossMarks = input.bool(false, "Show Cross Markers", group = grp3)

grp0 = "Core"
src         = input.source(close, "Source", group = grp0)
ma1Type     = input.string("EMA", "MA 1 Type", options = ["EMA", "SMA"], group = grp0)
ma1Len      = input.int(21, "MA 1 Length", minval = 1, group = grp0)
ma2Type     = input.string("EMA", "MA 2 Type", options = ["EMA", "SMA"], group = grp0)
ma2Len      = input.int(55, "MA 2 Length", minval = 1, group = grp0)

grp1 = "Colors"
bullColor    = input.color(color.rgb(33, 150, 243), "Bullish Color (Blue)", group = grp1)
bearColor    = input.color(color.rgb(242, 255, 66), "Bearish Color (Yellow)", group = grp1)
neutralColor = input.color(color.rgb(140, 140, 140), "Neutral Color", group = grp1)

grp2 = "Gradient Logic"
neutralZonePct = input.float(0.10, "Neutral Zone % Between MAs", minval = 0.0, step = 0.01, group = grp2)
fillAggressive = input.float(1.60, "Fill Aggressiveness", minval = 0.5, maxval = 4.0, step = 0.1, group = grp2)
outerOpacity   = input.int(96, "Outer Edge Opacity", minval = 0, maxval = 100, group = grp2)
innerOpacity   = input.int(78, "Inner Edge Opacity", minval = 0, maxval = 100, group = grp2)

// ── FUNCTIONS ──────────────────────────────────────────────────
clamp(_x, _min, _max) =>
    math.max(_min, math.min(_max, _x))

f_ma(_src, _len, _type) =>
    _type == "EMA" ? ta.ema(_src, _len) : ta.sma(_src, _len)

// ── MOVING AVERAGES ────────────────────────────────────────────
ma1 = f_ma(src, ma1Len, ma1Type)
ma2 = f_ma(src, ma2Len, ma2Type)

spread = math.abs(ma1 - ma2)
baseRange = ta.highest(spread, 200)
neutralThreshold = nz(((ma1 + ma2) / 2.0) * (neutralZonePct * 0.01), 0.0)

distNorm = not na(baseRange) and baseRange != 0
     ? clamp(math.pow(spread / baseRange, fillAggressive), 0.0, 1.0)
     : 0.0

isBull = ma1 > ma2
isBear = ma1 < ma2
isNeutral = spread <= neutralThreshold

topLine = math.max(ma1, ma2)
botLine = math.min(ma1, ma2)
step = topLine - botLine

// ── RIBBON LEVELS ──────────────────────────────────────────────
l1 = botLine + step * 0.16
l2 = botLine + step * 0.32
l3 = botLine + step * 0.48
l4 = botLine + step * 0.64
l5 = botLine + step * 0.80

// ── COLOR ENGINE ───────────────────────────────────────────────
lineColorFast =
     isNeutral ? neutralColor :
     isBull ? color.new(bullColor, 0) : color.new(bearColor, 0)

lineColorSlow =
     isNeutral ? color.new(neutralColor, 25) :
     isBull ? color.new(bullColor, 35) : color.new(bearColor, 35)

op1 = clamp(outerOpacity, 0, 100)
op2 = clamp(int(outerOpacity - (outerOpacity - innerOpacity) * 0.20), 0, 100)
op3 = clamp(int(outerOpacity - (outerOpacity - innerOpacity) * 0.40), 0, 100)
op4 = clamp(int(outerOpacity - (outerOpacity - innerOpacity) * 0.60), 0, 100)
op5 = clamp(int(outerOpacity - (outerOpacity - innerOpacity) * 0.80), 0, 100)
op6 = clamp(innerOpacity, 0, 100)

bull1 = color.new(bullColor, op1)
bull2 = color.new(bullColor, op2)
bull3 = color.new(bullColor, op3)
bull4 = color.new(bullColor, op4)
bull5 = color.new(bullColor, op5)
bull6 = color.new(bullColor, op6)

bear1 = color.new(bearColor, op1)
bear2 = color.new(bearColor, op2)
bear3 = color.new(bearColor, op3)
bear4 = color.new(bearColor, op4)
bear5 = color.new(bearColor, op5)
bear6 = color.new(bearColor, op6)

neut1 = color.new(neutralColor, 97)
neut2 = color.new(neutralColor, 96)
neut3 = color.new(neutralColor, 95)
neut4 = color.new(neutralColor, 94)
neut5 = color.new(neutralColor, 93)
neut6 = color.new(neutralColor, 92)

c1 = isNeutral ? neut1 : isBull ? bull1 : bear1
c2 = isNeutral ? neut2 : isBull ? bull2 : bear2
c3 = isNeutral ? neut3 : isBull ? bull3 : bear3
c4 = isNeutral ? neut4 : isBull ? bull4 : bear4
c5 = isNeutral ? neut5 : isBull ? bull5 : bear5
c6 = isNeutral ? neut6 : isBull ? bull6 : bear6

// ── PLOTS ──────────────────────────────────────────────────────
pMA1 = plot(showMAs ? ma1 : na, "MA 1", color = lineColorFast, linewidth = 2)
pMA2 = plot(showMAs ? ma2 : na, "MA 2", color = lineColorSlow, linewidth = 2)

// Invisible anchors for ribbon fill
pTop = plot(topLine, "Ribbon Top", color = color.new(color.white, 100), display = display.none)
pBot = plot(botLine, "Ribbon Bottom", color = color.new(color.white, 100), display = display.none)

pL1 = plot(l1, "Ribbon L1", color = color.new(color.white, 100), display = display.none)
pL2 = plot(l2, "Ribbon L2", color = color.new(color.white, 100), display = display.none)
pL3 = plot(l3, "Ribbon L3", color = color.new(color.white, 100), display = display.none)
pL4 = plot(l4, "Ribbon L4", color = color.new(color.white, 100), display = display.none)
pL5 = plot(l5, "Ribbon L5", color = color.new(color.white, 100), display = display.none)

// Directional ribbon
fill(pBot, pL1, color = c1, title = "Ribbon Layer 1")
fill(pL1, pL2, color = c2, title = "Ribbon Layer 2")
fill(pL2, pL3, color = c3, title = "Ribbon Layer 3")
fill(pL3, pL4, color = c4, title = "Ribbon Layer 4")
fill(pL4, pL5, color = c5, title = "Ribbon Layer 5")
fill(pL5, pTop, color = c6, title = "Ribbon Layer 6")

plotshape(showCrossMarks and ta.crossover(ma1, ma2),
     title = "Bullish Cross",
     style = shape.circle,
     location = location.belowbar,
     color = color.new(bullColor, 0),
     size = size.tiny)

plotshape(showCrossMarks and ta.crossunder(ma1, ma2),
     title = "Bearish Cross",
     style = shape.circle,
     location = location.abovebar,
     color = color.new(bearColor, 0),
     size = size.tiny)

// ── LABEL ──────────────────────────────────────────────────────
state =
     isNeutral ? "Compression" :
     isBull ? "Bullish Separation" :
     "Bearish Separation"

var label statusLbl = na

if barstate.islast
    label.delete(statusLbl)
    if showLabel
        lblColor = isNeutral ? neutralColor : isBull ? bullColor : bearColor
        lblText  = isNeutral ? "◆ COMPRESSION" : isBull ? "▲ BULLISH" : "▼ BEARISH"
        txtColor = isBear ? color.black : color.white
        statusLbl := label.new(
             bar_index + 2,
             topLine,
             text = lblText,
             style = label.style_label_left,
             color = color.new(lblColor, 0),
             textcolor = txtColor,
             size = size.small)

// ── ALERTS ─────────────────────────────────────────────────────
alertcondition(ta.crossover(ma1, ma2), "Bullish MA Cross", "Dual MA Gradient [Gabremoku] - Bullish crossover")
alertcondition(ta.crossunder(ma1, ma2), "Bearish MA Cross", "Dual MA Gradient [Gabremoku] - Bearish crossover")
````
