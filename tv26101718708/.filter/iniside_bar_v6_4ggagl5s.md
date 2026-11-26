# Iniside Bar v6

- url: https://www.tradingview.com/script/4GGaGl5s-Iniside-Bar-v6/
- type: indicator
- pine_id: PUB;108cb4bd09934e168f4c9b24ab6443df
- version: 2.0

## Description

Original Concept by: nilstrades_

Modified & Optimized by: marjyhen1921

Description

The Ib-1 Optimized is a high-precision volatility breakout tool designed to identify and trade the release of market tension. Built on the classic "Inside Bar" principle, this indicator adds a layer of intelligence by tracking "Mother Bar" ranges and using adaptive filters to ignore market noise and false breakouts.

The Strategy: Expansion & Contraction

Market movement is a cycle. When price forms an Inside Bar, it indicates a contraction (indecision). The previous bar (the Mother Bar) establishes a high-pressure zone. When price breaks out of this zone, it often leads to a powerful expansion.

Innovative Features

Adaptive Wick Expansion: Standard scripts often fail when a wick briefly pokes out of the range. This script includes a "Smart Expansion" toggle. If price wicks out but the body remains inside the range, the script stretches the boundary rather than resetting, keeping the trade setup active for the real move.

Single-Signal Execution: To eliminate chart clutter, the script is hard-coded to provide exactly one signal per breakout zone. Once a direction is confirmed, it locks the signal until a brand-new setup forms.

Touch vs. Confirmation Modes:

Touch Mode: Fires an alert the moment price hits the boundary (for aggressive entries).

Bar Close Mode: Fires only if the candle closes outside the boundary (for conservative confirmation).

Visual Clarity:

Yellow Barcolor: Indicates price is currently coiling within a zone.

Dynamic Gray Boxes: Visually maps the Mother Bar "No-Trade Zone" in real-time.

Breakout Triangles: Clearly marks the entry point for Long (Green) and Short (Red) trades.

How to Use

Monitor the Setup: Look for Yellow Bars and the appearance of the gray consolidation box.

Define the Risk: Use the boundaries of the gray box to help set your stop losses.

Execute: Enter the trade when the Green or Red Triangle appears based on your chosen Trigger Mode.

Acknowledgments

This version represents a significant technical evolution of the original breakout concepts. Special thanks to nilstrades_ for the foundational work that made this optimization possible. By refining the signal filtering and range-handling, we have created a cleaner, more reliable tool for modern market volatility.

Disclaimer

This script is a tool for technical analysis and does not guarantee profits. Always use proper risk management and consider market context (Volume, Trend, and News) before entering any trade.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © marjyhen1921

// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © marjyhen1921
// © nilstrades_

//@version=6
indicator("IB-3 Pro: IB-PRO3", overlay=true, max_labels_count=500, max_lines_count=500)

// ================= INPUTS =================
groupTS       = "Trading System"
atrLen        = input.int(14, "ATR Length", group=groupTS)
slMult        = input.float(1.5, "Stop Loss ATR Multiplier", group=groupTS)

tp1Mult       = input.float(1.0, "TP1 Multiplier", group=groupTS)
tp2Mult       = input.float(2.0, "TP2 Multiplier", group=groupTS)
tp3Mult       = input.float(3.0, "TP3 Multiplier", group=groupTS)
tp4Mult       = input.float(4.0, "TP4 Multiplier", group=groupTS)
tp5Mult       = input.float(5.0, "TP5 Multiplier", group=groupTS)
tp6Mult       = input.float(6.0, "TP6 Multiplier", group=groupTS)
tp7Mult       = input.float(7.0, "TP7 Multiplier", group=groupTS)

connectorMult = input.float(2.0, "Connector Length", group=groupTS)

groupIB       = "Inside Bar Logic"
expandRange   = input.bool(true, "Expand Range on Wick-Through", group=groupIB)
triggerMode   = input.string("Touch", "Trigger Mode", options=["Touch", "Bar Close"], group=groupIB)

groupF        = "Filter Logic"
useEmaFilter  = input.bool(true, "Enable EMA Filtering", group=groupF)

filterType    = input.string(
     "EMA 26",
     "Filter Based On:",
     options=["EMA 9", "EMA 26", "EMA Cross (9/26)"],
     group=groupF)

groupEmaToggle = "EMA Display Settings"
showEma50      = input.bool(true, "Show EMA 50", group=groupEmaToggle)
showEma200     = input.bool(true, "Show EMA 200", group=groupEmaToggle)

// ================= STATE VARIABLES =================
var int tradeDir = 0
var int entryBar = na

var float entryPrice = na
var float slPrice = na

var float tp1 = na
var float tp2 = na
var float tp3 = na
var float tp4 = na
var float tp5 = na
var float tp6 = na
var float tp7 = na

var float highBeforeIB = na
var float lowBeforeIB  = na

var bool inIB = false

var float shadowHigh = na
var float shadowLow  = na

var bool tp1_h = false
var bool tp2_h = false
var bool tp3_h = false
var bool tp4_h = false
var bool tp5_h = false
var bool tp6_h = false
var bool tp7_h = false

var bool sl_h = false
var bool revExit_h = false

var int bCount = 0
var int sCount = 0

// ================= DAILY RESET =================
if ta.change(time("D")) != 0
    bCount := 0
    sCount := 0
    tradeDir := 0
    inIB := false

// ================= CALCULATIONS =================
atr    = ta.atr(atrLen)

ema9   = ta.ema(close, 9)
ema26  = ta.ema(close, 26)
ema50  = ta.ema(close, 50)
ema200 = ta.ema(close, 200)

offset = atr * connectorMult

isInsideBar = high <= high[1] and low >= low[1]

// ================= INSIDE BAR =================
if isInsideBar and not inIB
    highBeforeIB := high[1]
    lowBeforeIB  := low[1]
    inIB := true

if inIB

    if expandRange

        if high > highBeforeIB and math.max(open, close) <= highBeforeIB
            highBeforeIB := high

        if low < lowBeforeIB and math.min(open, close) >= lowBeforeIB
            lowBeforeIB := low

// ================= FILTERS =================
bool bullFilter = true
bool bearFilter = true

if useEmaFilter

    if filterType == "EMA 9"
        bullFilter := high > ema9
        bearFilter := low < ema9

    else if filterType == "EMA 26"
        bullFilter := high > ema26
        bearFilter := low < ema26

    else if filterType == "EMA Cross (9/26)"
        bullFilter := ema9 > ema26
        bearFilter := ema9 < ema26

float pCheckUp = triggerMode == "Touch" ? high : close
float pCheckDn = triggerMode == "Touch" ? low : close

// ================= REVERSAL EXIT =================
if tradeDir != 0 and bar_index > entryBar and not tp1_h and not sl_h and not revExit_h

    // BUY -> SELL
    if tradeDir == 1 and pCheckDn < shadowLow

        revExit_h := true

        y = low - (offset * 0.5)

        line.new(bar_index, low, bar_index, y, color=color.orange, width=2)

        label.new(
             bar_index,
             y,
             "xBTP1-" + str.tostring(bCount),
             style=label.style_label_down,
             color=color.fuchsia,
             textcolor=color.black,
             size=size.tiny)

        tradeDir := 0

    // SELL -> BUY
    else if tradeDir == -1 and pCheckUp > shadowHigh

        revExit_h := true

        y = high + (offset * 0.5)

        line.new(bar_index, high, bar_index, y, color=color.purple, width=2)

        label.new(
             bar_index,
             y,
             "xSTP1-" + str.tostring(sCount),
             style=label.style_label_up,
             color=color.fuchsia,
             textcolor=color.black,
             size=size.tiny)

        tradeDir := 0

// ================= SIGNALS =================
bool buySig  = inIB and pCheckUp > highBeforeIB and bullFilter
bool sellSig = inIB and pCheckDn < lowBeforeIB and bearFilter

// ================= BUY -> BUY =================
if buySig and tradeDir == 1 and bar_index > entryBar and not tp1_h and not sl_h

    revExit_h := true

    y = high + (offset * 0.5)

    line.new(bar_index, high, bar_index, y, color=color.orange, width=2)

    label.new(
         bar_index,
         y,
         "xBTP1-" + str.tostring(bCount),
         style=label.style_label_down,
         color=color.fuchsia,
         textcolor=color.black,
         size=size.tiny)

// ================= SELL -> SELL =================
if sellSig and tradeDir == -1 and bar_index > entryBar and not tp1_h and not sl_h

    revExit_h := true

    y = low - (offset * 0.5)

    line.new(bar_index, low, bar_index, y, color=color.purple, width=2)

    label.new(
         bar_index,
         y,
         "xSTP1-" + str.tostring(sCount),
         style=label.style_label_up,
         color=color.fuchsia,
         textcolor=color.black,
         size=size.tiny)

// ================= BUY EXECUTION =================
if buySig and (tradeDir <= 0 or tradeDir == 1)

    tradeDir := 1

    bCount += 1

    entryBar := bar_index
    entryPrice := highBeforeIB

    shadowHigh := highBeforeIB
    shadowLow  := lowBeforeIB

    slPrice := entryPrice - (atr * slMult)

    tp1 := entryPrice + (atr * tp1Mult)
    tp2 := entryPrice + (atr * tp2Mult)
    tp3 := entryPrice + (atr * tp3Mult)
    tp4 := entryPrice + (atr * tp4Mult)
    tp5 := entryPrice + (atr * tp5Mult)
    tp6 := entryPrice + (atr * tp6Mult)
    tp7 := entryPrice + (atr * tp7Mult)

    tp1_h := false
    tp2_h := false
    tp3_h := false
    tp4_h := false
    tp5_h := false
    tp6_h := false
    tp7_h := false

    sl_h := false
    revExit_h := false

    txt =
         "BUY #" + str.tostring(bCount) +
         "\nEP: " + str.tostring(entryPrice, format.mintick) +
         "\nSL: " + str.tostring(slPrice, format.mintick) +
         "\nTP1: " + str.tostring(tp1, format.mintick) +
         "\nTP2: " + str.tostring(tp2, format.mintick) +
         "\nTP3: " + str.tostring(tp3, format.mintick) +
         "\nTP4: " + str.tostring(tp4, format.mintick) +
         "\nTP5: " + str.tostring(tp5, format.mintick) +
         "\nTP6: " + str.tostring(tp6, format.mintick) +
         "\nTP7: " + str.tostring(tp7, format.mintick)

    y = low - offset

    line.new(bar_index, low, bar_index, y, color=color.green, width=2)

    label.new(
         bar_index,
         y,
         txt,
         style=label.style_label_up,
         color=color.blue,
         textcolor=color.white,
         size=size.small)

    inIB := false
    highBeforeIB := na
    lowBeforeIB := na

// ================= SELL EXECUTION =================
if sellSig and (tradeDir >= 0 or tradeDir == -1)

    tradeDir := -1

    sCount += 1

    entryBar := bar_index
    entryPrice := lowBeforeIB

    shadowHigh := highBeforeIB
    shadowLow  := lowBeforeIB

    slPrice := entryPrice + (atr * slMult)

    tp1 := entryPrice - (atr * tp1Mult)
    tp2 := entryPrice - (atr * tp2Mult)
    tp3 := entryPrice - (atr * tp3Mult)
    tp4 := entryPrice - (atr * tp4Mult)
    tp5 := entryPrice - (atr * tp5Mult)
    tp6 := entryPrice - (atr * tp6Mult)
    tp7 := entryPrice - (atr * tp7Mult)

    tp1_h := false
    tp2_h := false
    tp3_h := false
    tp4_h := false
    tp5_h := false
    tp6_h := false
    tp7_h := false

    sl_h := false
    revExit_h := false

    txt =
         "SELL #" + str.tostring(sCount) +
         "\nEP: " + str.tostring(entryPrice, format.mintick) +
         "\nSL: " + str.tostring(slPrice, format.mintick) +
         "\nTP1: " + str.tostring(tp1, format.mintick) +
         "\nTP2: " + str.tostring(tp2, format.mintick) +
         "\nTP3: " + str.tostring(tp3, format.mintick) +
         "\nTP4: " + str.tostring(tp4, format.mintick) +
         "\nTP5: " + str.tostring(tp5, format.mintick) +
         "\nTP6: " + str.tostring(tp6, format.mintick) +
         "\nTP7: " + str.tostring(tp7, format.mintick)

    y = high + offset

    line.new(bar_index, high, bar_index, y, color=color.red, width=2)

    label.new(
         bar_index,
         y,
         txt,
         style=label.style_label_down,
         color=color.yellow,
         textcolor=color.black,
         size=size.small)

    inIB := false
    highBeforeIB := na
    lowBeforeIB := na

// ================= MONITOR TP/SL =================
if tradeDir != 0 and bar_index > entryBar

    // ================= LONG =================
    if tradeDir == 1

        // SL
        if not sl_h and low <= slPrice

            sl_h := true

            line.new(bar_index, low, bar_index, low - (offset * 0.5), color=color.red, width=2)

            label.new(
                 bar_index,
                 low - (offset * 0.5),
                 "SLB-" + str.tostring(bCount),
                 style=label.style_label_up,
                 color=color.red,
                 textcolor=color.white,
                 size=size.small)

            tradeDir := 0

        // TP1
        if not tp1_h and high >= tp1

            tp1_h := true

            line.new(bar_index, high, bar_index, high + (offset * 0.5), color=#CD7F32, width=2)

            label.new(bar_index, high + (offset * 0.5), "BTP1-" + str.tostring(bCount), style=label.style_label_down, color=#CD7F32, textcolor=color.black, size=size.tiny)

        // TP2
        if not tp2_h and high >= tp2

            tp2_h := true

            line.new(bar_index, high, bar_index, high + (offset * 0.6), color=color.yellow, width=2)

            label.new(bar_index, high + (offset * 0.6), "BTP2-" + str.tostring(bCount), style=label.style_label_down, color=color.yellow, textcolor=color.black, size=size.tiny)

        // TP3
        if not tp3_h and high >= tp3

            tp3_h := true

            line.new(bar_index, high, bar_index, high + (offset * 0.7), color=color.lime, width=2)

            label.new(bar_index, high + (offset * 0.7), "BTP3-" + str.tostring(bCount), style=label.style_label_down, color=color.lime, textcolor=color.black, size=size.tiny)

        // TP4
        if not tp4_h and high >= tp4

            tp4_h := true

            line.new(bar_index, high, bar_index, high + (offset * 0.8), color=color.green, width=2)

            label.new(bar_index, high + (offset * 0.8), "BTP4-" + str.tostring(bCount), style=label.style_label_down, color=color.green, textcolor=color.white, size=size.tiny)

        // TP5
        if not tp5_h and high >= tp5

            tp5_h := true

            line.new(bar_index, high, bar_index, high + (offset * 0.9), color=color.aqua, width=2)

            label.new(bar_index, high + (offset * 0.9), "BTP5-" + str.tostring(bCount), style=label.style_label_down, color=color.aqua, textcolor=color.black, size=size.tiny)

        // TP6
        if not tp6_h and high >= tp6

            tp6_h := true

            line.new(bar_index, high, bar_index, high + offset, color=color.blue, width=2)

            label.new(bar_index, high + offset, "BTP6-" + str.tostring(bCount), style=label.style_label_down, color=color.blue, textcolor=color.white, size=size.tiny)

        // TP7
        if not tp7_h and high >= tp7

            tp7_h := true

            line.new(bar_index, high, bar_index, high + (offset * 1.1), color=color.white, width=2)

            label.new(bar_index, high + (offset * 1.1), "BTP7-" + str.tostring(bCount), style=label.style_label_down, color=color.white, textcolor=color.black, size=size.tiny)

    // ================= SHORT =================
    if tradeDir == -1

        // SL
        if not sl_h and high >= slPrice

            sl_h := true

            line.new(bar_index, high, bar_index, high + (offset * 0.5), color=color.red, width=2)

            label.new(
                 bar_index,
                 high + (offset * 0.5),
                 "SLS-" + str.tostring(sCount),
                 style=label.style_label_down,
                 color=color.red,
                 textcolor=color.white,
                 size=size.small)

            tradeDir := 0

        // TP1
        if not tp1_h and low <= tp1

            tp1_h := true

            line.new(bar_index, low, bar_index, low - (offset * 0.5), color=#CD7F32, width=2)

            label.new(bar_index, low - (offset * 0.5), "STP1-" + str.tostring(sCount), style=label.style_label_up, color=#CD7F32, textcolor=color.black, size=size.tiny)

        // TP2
        if not tp2_h and low <= tp2

            tp2_h := true

            line.new(bar_index, low, bar_index, low - (offset * 0.6), color=color.yellow, width=2)

            label.new(bar_index, low - (offset * 0.6), "STP2-" + str.tostring(sCount), style=label.style_label_up, color=color.yellow, textcolor=color.black, size=size.tiny)

        // TP3
        if not tp3_h and low <= tp3

            tp3_h := true

            line.new(bar_index, low, bar_index, low - (offset * 0.7), color=color.lime, width=2)

            label.new(bar_index, low - (offset * 0.7), "STP3-" + str.tostring(sCount), style=label.style_label_up, color=color.lime, textcolor=color.black, size=size.tiny)

        // TP4
        if not tp4_h and low <= tp4

            tp4_h := true

            line.new(bar_index, low, bar_index, low - (offset * 0.8), color=color.green, width=2)

            label.new(bar_index, low - (offset * 0.8), "STP4-" + str.tostring(sCount), style=label.style_label_up, color=color.green, textcolor=color.white, size=size.tiny)

        // TP5
        if not tp5_h and low <= tp5

            tp5_h := true

            line.new(bar_index, low, bar_index, low - (offset * 0.9), color=color.aqua, width=2)

            label.new(bar_index, low - (offset * 0.9), "STP5-" + str.tostring(sCount), style=label.style_label_up, color=color.aqua, textcolor=color.black, size=size.tiny)

        // TP6
        if not tp6_h and low <= tp6

            tp6_h := true

            line.new(bar_index, low, bar_index, low - offset, color=color.blue, width=2)

            label.new(bar_index, low - offset, "STP6-" + str.tostring(sCount), style=label.style_label_up, color=color.blue, textcolor=color.white, size=size.tiny)

        // TP7
        if not tp7_h and low <= tp7

            tp7_h := true

            line.new(bar_index, low, bar_index, low - (offset * 1.1), color=color.white, width=2)

            label.new(bar_index, low - (offset * 1.1), "STP7-" + str.tostring(sCount), style=label.style_label_up, color=color.white, textcolor=color.black, size=size.tiny)

// ================= VISUALS =================
plot(ema9, "EMA 9", color=color.new(color.blue, 50))

plot(
     ema26,
     "EMA 26",
     color=color.new(color.orange, 50),
     linewidth=2)

// Conditional EMA 50 & 200 Plots
plot(showEma50 ? ema50 : na, "EMA 50", color=color.new(color.purple, 30), linewidth=2)
plot(showEma200 ? ema200 : na, "EMA 200", color=color.new(color.red, 30), linewidth=3)

barcolor(inIB ? color.new(color.yellow, 0) : na)

hiPlot = plot(
     highBeforeIB,
     "Range High",
     style=plot.style_linebr,
     color=color.new(color.gray, 60),
     linewidth=2)

loPlot = plot(
     lowBeforeIB,
     "Range Low",
     style=plot.style_linebr,
     color=color.new(color.gray, 60),
     linewidth=2)

fill(
     hiPlot,
     loPlot,
     color.new(color.gray, 90),
     title="Inside Bar Box")

// ================= BREAKOUT PLOTS =================
plotshape(
     buySig,
     title="Buy Breakout",
     style=shape.triangleup,
     location=location.belowbar,
     color=color.green,
     size=size.small)

plotshape(
     sellSig,
     title="Sell Breakout",
     style=shape.triangledown,
     location=location.abovebar,
     color=color.red,
     size=size.small)

    // ================= ALERTS =================

// Buy Alert
alertcondition(
     buySig,
     title = "BUY Alert",
     message = "BUY Signal on {{ticker}} @ {{close}}"
)

// Sell Alert
alertcondition(
     sellSig,
     title = "SELL Alert",
     message = "SELL Signal on {{ticker}} @ {{close}}"
)
````
