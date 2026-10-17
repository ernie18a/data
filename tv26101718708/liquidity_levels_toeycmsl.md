# Liquidity Levels.

- url: https://www.tradingview.com/script/tOEyCmSL-Liquidity-Levels/
- type: indicator
- pine_id: PUB;61708e2f5a1f493d85368a883ed7baea
- version: 2.0

## Description

OVERVIEW
This indicator marks resting liquidity on the chart by drawing horizontal lines at confirmed swing highs and swing lows. In price-action and Smart Money concepts, swing highs tend to hold buy-side liquidity (buy stops from breakout buyers and short-sellers' protective stops), while swing lows tend to hold sell-side liquidity (sell stops). Visualising these levels helps traders see where orders are likely resting and where price may be drawn before continuing or reversing.

HOW IT WORKS
The script uses pivot detection to identify swing points. A swing high is confirmed when a candle's high is higher than the highs of the surrounding bars on both sides; a swing low is confirmed when a candle's low is lower than the lows of the surrounding bars on both sides. The number of bars required on each side is controlled by the Swing Lookback input. Because a pivot needs bars on both sides to confirm, levels print after the lookback period has elapsed — they do not repaint once drawn.

Each confirmed swing plots a dashed line at that price. Lines can optionally extend to the right so you can track whether a level remains untapped on the current candle.

INPUTS
- Swing Lookback: bars required on each side of a pivot. Higher values isolate more significant swing points and reduce minor levels.
- Show Buy-Side Liquidity (highs): toggles swing-high lines.
- Show Sell-Side Liquidity (lows): toggles swing-low lines.
- Extend Lines Right: extends levels forward for easier tracking.
- Liquidity Line Color and Line Width: visual styling.

HOW TO USE
- Raise the Swing Lookback on higher timeframes to focus on major liquidity; lower it on intraday charts for finer levels.
- Watch for price reaching an untapped level. A sweep (price piercing the level then closing back) can signal that liquidity has been taken, which some traders use as a reversal cue when combined with their own confirmation.
- This tool only maps levels. It does not generate entries, targets, or signals, and is best combined with your own market-structure or confirmation method.

NOTES
This is a visualisation tool, not a trading system, and does not constitute financial advice. Test any approach on your own before applying it to live decisions.

## Source Code

````pine
//@version=6
indicator("Liquidity Levels [TheBitcoin537]", shorttitle="Liquidity", overlay=true, max_lines_count=500, max_labels_count=500)

// ============================================================
//                          INPUTS
// ============================================================
grpDetect = "Detection"
swingLen   = input.int(10, "Swing Lookback", minval=2, group=grpDetect, tooltip="Bars each side of a pivot used to define swing highs/lows (liquidity).")
maxLevels  = input.int(20, "Max Levels Per Side", minval=1, maxval=100, group=grpDetect, tooltip="How many recent swing highs and lows to track for sweeps.")

grpShow = "Visibility"
showHigh     = input.bool(true, "Show Buy-Side Liquidity (highs)", group=grpShow)
showLow      = input.bool(true, "Show Sell-Side Liquidity (lows)", group=grpShow)
showUnswept  = input.bool(true, "Show Unswept Levels", group=grpShow)
showSwept    = input.bool(true, "Show Swept Levels", group=grpShow)
extendRight  = input.bool(true, "Extend Unswept Lines Right", group=grpShow)

grpSweep = "Sweep Logic"
sweepBasis = input.string("Wick", "Sweep Trigger", options=["Wick", "Close"], group=grpSweep, tooltip="Wick = level counts as swept the moment price pierces it. Close = only when a candle closes through it.")
stopAtSweep = input.bool(true, "Stop Line at Sweep Candle", group=grpSweep, tooltip="When swept, freeze the line at the candle that took it instead of extending.")
markSweep   = input.bool(true, "Mark Sweep with ✕ Label", group=grpSweep)

grpUnsweptStyle = "Unswept Style"
unsweptCol   = input.color(#D4AF37, "Unswept Color", group=grpUnsweptStyle)
unsweptWidth = input.int(2, "Unswept Width", minval=1, maxval=4, group=grpUnsweptStyle)
unsweptStyle = input.string("Solid", "Unswept Line Style", options=["Solid", "Dashed", "Dotted"], group=grpUnsweptStyle)

grpSweptStyle = "Swept Style"
sweptCol     = input.color(color.new(#787B86, 30), "Swept Color", group=grpSweptStyle)
sweptWidth   = input.int(1, "Swept Width", minval=1, maxval=4, group=grpSweptStyle)
sweptStyle   = input.string("Dotted", "Swept Line Style", options=["Solid", "Dashed", "Dotted"], group=grpSweptStyle)

// ============================================================
//                       STYLE HELPERS
// ============================================================
getStyle(s) =>
    s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted

unsweptLineStyle = getStyle(unsweptStyle)
sweptLineStyle   = getStyle(sweptStyle)

// ============================================================
//                       LEVEL STORAGE
// ============================================================
// Parallel arrays: line object, price, swept flag, type (true = high/buy-side)
var line[]  levLines  = array.new<line>()
var float[] levPrice  = array.new<float>()
var bool[]  levSwept  = array.new<bool>()
var bool[]  levIsHigh = array.new<bool>()

ext = extendRight ? extend.right : extend.none

// ---- create a new level line ----
newLevel(price, isHigh) =>
    ln = line.new(bar_index - swingLen, price, bar_index, price, color=unsweptCol, width=unsweptWidth, extend=ext, style=unsweptLineStyle)
    array.push(levLines, ln)
    array.push(levPrice, price)
    array.push(levSwept, false)
    array.push(levIsHigh, isHigh)
    // cap total stored lines per side by trimming oldest of that side
    cnt = 0
    k = array.size(levIsHigh) - 1
    while k >= 0
        if array.get(levIsHigh, k) == isHigh
            cnt += 1
            if cnt > maxLevels
                line.delete(array.get(levLines, k))
                array.remove(levLines, k)
                array.remove(levPrice, k)
                array.remove(levSwept, k)
                array.remove(levIsHigh, k)
        k -= 1

// ============================================================
//                     SWING DETECTION
// ============================================================
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

if not na(ph) and showHigh
    newLevel(ph, true)
if not na(pl) and showLow
    newLevel(pl, false)

// ============================================================
//                     SWEEP MONITORING
// ============================================================
i = 0
while i < array.size(levPrice)
    if not array.get(levSwept, i)
        p  = array.get(levPrice, i)
        isH = array.get(levIsHigh, i)
        ln = array.get(levLines, i)
        // determine sweep
        swept = false
        if isH
            swept := sweepBasis == "Wick" ? high > p : close > p
        else
            swept := sweepBasis == "Wick" ? low < p : close < p

        if swept
            array.set(levSwept, i, true)
            // restyle as swept
            line.set_color(ln, sweptCol)
            line.set_width(ln, sweptWidth)
            line.set_style(ln, sweptLineStyle)
            if stopAtSweep
                line.set_extend(ln, extend.none)
                line.set_x2(ln, bar_index)
            if not showSwept
                line.delete(ln)
            if markSweep and showSwept
                label.new(bar_index, p, "✕", style=isH ? label.style_label_down : label.style_label_up, color=color.new(sweptCol, 60), textcolor=sweptCol, size=size.tiny)
    i += 1

// ---- enforce visibility toggles on already-stored lines ----
j = 0
while j < array.size(levLines)
    ln = array.get(levLines, j)
    sw = array.get(levSwept, j)
    if sw and not showSwept
        line.set_color(ln, color.new(color.gray, 100))
    if not sw and not showUnswept
        line.set_color(ln, color.new(color.gray, 100))
    j += 1
````
