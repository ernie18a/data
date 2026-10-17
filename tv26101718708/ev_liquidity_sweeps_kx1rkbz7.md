# EV Liquidity Sweeps 

- url: https://www.tradingview.com/script/KX1Rkbz7-EV-Liquidity-Sweeps/
- type: indicator
- pine_id: PUB;582d3bb5540a4efa98d8d9d524796d4f
- version: 1.0

## Description

This indicator is designed to detect liquidity sweeps and stop hunts by identifying when price briefly moves beyond key swing highs or lows and then rejects those levels. It highlights areas where buy-side or sell-side liquidity has been taken, offering traders a clear and objective way to read liquidity-driven market behavior.

Buy-side liquidity sweeps occur when price trades above a previous swing high and fails to hold, while sell-side liquidity sweeps occur when price trades below a previous swing low and quickly recovers. All detections are based on confirmed pivots, ensuring the indicator is fully non-repainting and reliable in live trading conditions.

The indicator allows users to choose between close-based or wick-based confirmation and can optionally mark only the first sweep of each liquidity level to reduce chart noise. Liquidity levels can be visualized directly on the chart, providing precise contextual references for market structure, VWAP confluence, and potential reversals.
Apr 8
Release Notes
EV Liquidity Sweeps detects when price runs above swing highs or below swing lows to sweep resting liquidity, then confirms whether it reversed — the core setup behind stop hunts, liquidity grabs, and smart money entries.

What makes it different:

Multi-level tracking — monitors the last N swing highs and lows simultaneously, not just the most recent one. Sweeps are detected across all active levels
Equal Highs/Lows detection — when multiple pivots cluster at the same price, they are merged into a single EQL zone tagged as [EQL×3] in orange. These pooled liquidity areas attract price more aggressively and produce stronger reactions
Sweep depth filter — minimum ATR-based depth required before a sweep is marked, eliminating noise from shallow wicks that barely touch a level
Reversal confirmation — after a sweep, the indicator checks the next N bars for a strong reversal candle. If found, it adds a "↑ Reversal" or "↓ Reversal" label, helping you time entries
Depth in pips — every label shows exactly how deep the sweep went (e.g. "Buy Liq +18p"), so you can quickly assess the conviction behind the move
Max level age — stale levels are automatically ignored so only relevant structure is tracked
Settings:

Pivot length and max levels tracked simultaneously
Sweep confirmation: Close (stricter) or Wick (faster)
ATR-based minimum sweep depth
Equal highs/lows merge threshold
Reversal confirmation toggle and lookback bars
Full color control for buy-side, sell-side, and EQL levels
Alerts (4 conditions):

Buy-side liquidity swept
Sell-side liquidity swept
Buy-side sweep + bearish reversal confirmed
Sell-side sweep + bullish reversal confirmed

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © EV Quant Lab

//@version=6
indicator("EV Liquidity Sweeps ", shorttitle="Liq", overlay=true, max_labels_count=500, max_lines_count=500)

// ─────────────────────────────────────────────
// GROUPS
// ─────────────────────────────────────────────
g1 = "Liquidity"
g2 = "Filters"
g3 = "Post-Sweep"
g4 = "Equal Highs/Lows"
g5 = "Style"
g6 = "Alerts"

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────
pivotLen  = input.int(5,      "Pivot Length",             minval=1, maxval=20,  group=g1)
maxLevels = input.int(5,      "Max Levels Tracked",       minval=1, maxval=10,  group=g1)
confirmBy = input.string("Close", "Sweep Confirmation",   options=["Close","Wick"], group=g1)
firstOnly = input.bool(true,  "Mark Only First Sweep per Level",                group=g1)
drawLevel = input.bool(true,  "Draw Liquidity Level Line",                      group=g1)

atrLen     = input.int(14,   "ATR Length",                                      group=g2)
minDepthM  = input.float(0.1,"Min Sweep Depth (ATR Mult)", minval=0.0, step=0.05, group=g2)
maxAge     = input.int(200,  "Max Level Age (bars)",       minval=10,            group=g2)

showReversal  = input.bool(true, "Show Reversal Confirmation",                  group=g3)
revBars       = input.int(3,     "Reversal Bars to Check",  minval=1, maxval=10, group=g3)

showEQL    = input.bool(true,  "Detect Equal Highs/Lows (Pooled Liquidity)",   group=g4)
eqlThresh  = input.float(0.1,  "EQL Merge Threshold (ATR)", minval=0.0, step=0.05, group=g4)

colBuy     = input.color(color.new(#f44336, 0),  "Buy-Side Color",             group=g5)
colSell    = input.color(color.new(#00c853, 0),  "Sell-Side Color",            group=g5)
colEQL     = input.color(color.new(#ff9800, 0),  "Equal H/L Color",            group=g5)
lvlWidth   = input.int(1, "Level Line Width",    minval=1, maxval=3,            group=g5)
txtSize    = input.string("small", "Label Size", options=["tiny","small","normal"], group=g5)

alertBuy   = input.bool(true, "Alert: Buy-Side Sweep",     group=g6)
alertSell  = input.bool(true, "Alert: Sell-Side Sweep",    group=g6)
alertRev   = input.bool(true, "Alert: Sweep + Reversal",   group=g6)

// ─────────────────────────────────────────────
// CORE
// ─────────────────────────────────────────────
atr      = ta.atr(atrLen)
minDepth = atr * minDepthM
eqlTH    = atr * eqlThresh

f_size(s) => s == "tiny" ? size.tiny : s == "small" ? size.small : size.normal

// ─────────────────────────────────────────────
// PIVOT LEVEL TRACKING (last N highs + lows)
// ─────────────────────────────────────────────
var float[] phPrices = array.new_float()
var int[]   phTimes  = array.new_int()
var int[]   phBars   = array.new_int()
var bool[]  phSwept  = array.new_bool()
var int[]   phCount  = array.new_int()   // how many pivots merged (EQL)

var float[] plPrices = array.new_float()
var int[]   plTimes  = array.new_int()
var int[]   plBars   = array.new_int()
var bool[]  plSwept  = array.new_bool()
var int[]   plCount  = array.new_int()

ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low,   pivotLen, pivotLen)
pivotTime = time[pivotLen]
pivotBar  = bar_index[pivotLen]

// Add pivot high — merge into existing if within EQL threshold
if not na(ph)
    merged = false
    if showEQL
        n = array.size(phPrices)
        if n > 0
            for i = 0 to n - 1
                ep = array.get(phPrices, i)
                if math.abs(ph - ep) <= eqlTH
                    cnt = array.get(phCount, i)
                    array.set(phPrices, i, (ep * cnt + ph) / (cnt + 1))
                    array.set(phCount,  i, cnt + 1)
                    array.set(phTimes,  i, pivotTime)
                    array.set(phBars,   i, pivotBar)
                    array.set(phSwept,  i, false)
                    merged := true
                    break
    if not merged
        array.push(phPrices, ph)
        array.push(phTimes,  pivotTime)
        array.push(phBars,   pivotBar)
        array.push(phSwept,  false)
        array.push(phCount,  1)
        if array.size(phPrices) > maxLevels
            array.shift(phPrices)
            array.shift(phTimes)
            array.shift(phBars)
            array.shift(phSwept)
            array.shift(phCount)

// Add pivot low
if not na(pl)
    merged = false
    if showEQL
        n = array.size(plPrices)
        if n > 0
            for i = 0 to n - 1
                ep = array.get(plPrices, i)
                if math.abs(pl - ep) <= eqlTH
                    cnt = array.get(plCount, i)
                    array.set(plPrices, i, (ep * cnt + pl) / (cnt + 1))
                    array.set(plCount,  i, cnt + 1)
                    array.set(plTimes,  i, pivotTime)
                    array.set(plBars,   i, pivotBar)
                    array.set(plSwept,  i, false)
                    merged := true
                    break
    if not merged
        array.push(plPrices, pl)
        array.push(plTimes,  pivotTime)
        array.push(plBars,   pivotBar)
        array.push(plSwept,  false)
        array.push(plCount,  1)
        if array.size(plPrices) > maxLevels
            array.shift(plPrices)
            array.shift(plTimes)
            array.shift(plBars)
            array.shift(plSwept)
            array.shift(plCount)

// ─────────────────────────────────────────────
// SWEEP DETECTION
// ─────────────────────────────────────────────
var bool sigBuy     = false
var bool sigSell    = false
var bool sigRevBull = false
var bool sigRevBear = false
sigBuy     := false
sigSell    := false
sigRevBull := false
sigRevBear := false

// Reversal detection: did price close back strongly within revBars candles?
f_reversal_bull() =>
    // After sweeping a low: next N bars must have at least one strong bullish close
    result = false
    if barstate.isconfirmed
        for k = 0 to revBars - 1
            if close[k] > open[k] and (close[k] - open[k]) > atr * 0.3
                result := true
    result

f_reversal_bear() =>
    result = false
    if barstate.isconfirmed
        for k = 0 to revBars - 1
            if close[k] < open[k] and (open[k] - close[k]) > atr * 0.3
                result := true
    result

f_depth_label(swept_price, is_high) =>
    depth = is_high ? high - swept_price : swept_price - low
    pips  = math.round(depth / syminfo.mintick)
    " +" + str.tostring(pips) + "p"

// Check highs (buy-side sweep = price wicked above high then closed below)
nH = array.size(phPrices)
if nH > 0
    for i = nH - 1 to 0
        p      = array.get(phPrices, i)
        t      = array.get(phTimes,  i)
        b      = array.get(phBars,   i)
        swept  = array.get(phSwept,  i)
        cnt    = array.get(phCount,  i)
        age    = bar_index - b

        if age <= maxAge and (not firstOnly or not swept) and high > p and (high - p) >= minDepth
            confirmed = confirmBy == "Wick" ? true : close < p
            if confirmed
                array.set(phSwept, i, true)
                sigBuy := true

                isEQL = showEQL and cnt >= 2
                col   = isEQL ? colEQL : colBuy
                depth = f_depth_label(p, true)
                eqlTxt = isEQL ? " [EQL×" + str.tostring(cnt) + "]" : ""
                lbl   = "Buy Liq" + eqlTxt + depth

                if drawLevel and not na(t)
                    line.new(x1=t, y1=p, x2=time, y2=p, xloc=xloc.bar_time,
                             extend=extend.none, color=col, width=lvlWidth, style=line.style_dashed)

                label.new(x=time, y=high, xloc=xloc.bar_time,
                    style=label.style_label_down, text=lbl,
                    textcolor=color.white, color=col, size=f_size(txtSize))

                if showReversal and f_reversal_bear()
                    sigRevBear := true
                    label.new(x=time, y=high + atr * 0.3, xloc=xloc.bar_time,
                        style=label.style_label_down, text="↓ Reversal",
                        textcolor=color.white, color=color.new(colBuy, 20), size=size.tiny)

// Check lows (sell-side sweep = price wicked below low then closed above)
nL = array.size(plPrices)
if nL > 0
    for i = nL - 1 to 0
        p      = array.get(plPrices, i)
        t      = array.get(plTimes,  i)
        b      = array.get(plBars,   i)
        swept  = array.get(plSwept,  i)
        cnt    = array.get(plCount,  i)
        age    = bar_index - b

        if age <= maxAge and (not firstOnly or not swept) and low < p and (p - low) >= minDepth
            confirmed = confirmBy == "Wick" ? true : close > p
            if confirmed
                array.set(plSwept, i, true)
                sigSell := true

                isEQL = showEQL and cnt >= 2
                col   = isEQL ? colEQL : colSell
                depth = f_depth_label(p, false)
                eqlTxt = isEQL ? " [EQL×" + str.tostring(cnt) + "]" : ""
                lbl   = "Sell Liq" + eqlTxt + depth

                if drawLevel and not na(t)
                    line.new(x1=t, y1=p, x2=time, y2=p, xloc=xloc.bar_time,
                             extend=extend.none, color=col, width=lvlWidth, style=line.style_dashed)

                label.new(x=time, y=low, xloc=xloc.bar_time,
                    style=label.style_label_up, text=lbl,
                    textcolor=color.white, color=col, size=f_size(txtSize))

                if showReversal and f_reversal_bull()
                    sigRevBull := true
                    label.new(x=time, y=low - atr * 0.3, xloc=xloc.bar_time,
                        style=label.style_label_up, text="↑ Reversal",
                        textcolor=color.white, color=color.new(colSell, 20), size=size.tiny)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────
alertcondition(alertBuy  and sigBuy,     title="Buy-Side Sweep",         message="Buy-side liquidity swept on {{ticker}} {{interval}}")
alertcondition(alertSell and sigSell,    title="Sell-Side Sweep",        message="Sell-side liquidity swept on {{ticker}} {{interval}}")
alertcondition(alertRev  and sigRevBear, title="Sweep + Bearish Reversal", message="Buy-side sweep + bearish reversal on {{ticker}} {{interval}}")
alertcondition(alertRev  and sigRevBull, title="Sweep + Bullish Reversal", message="Sell-side sweep + bullish reversal on {{ticker}} {{interval}}")
````
