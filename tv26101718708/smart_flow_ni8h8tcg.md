# Smart Flow

- url: https://www.tradingview.com/script/NI8h8TCG-Smart-Flow/
- type: indicator
- pine_id: PUB;1e2fbb4b6d70426981e90f29ec2a078e
- version: 1.0

## Description

Smart Flow indicator which can help to determine trends in trading

## Source Code

````pine
// ════════════════════════════════════════════════════════════════════════════
//  SMART FLOW — SMC Indicator  |  Pine Script v5
//  Features: BOS, CHoCH, Order Blocks, Fair Value Gaps,
//            Liquidity Sweeps, Trend Color, Buy/Sell Signals
// ════════════════════════════════════════════════════════════════════════════
//@version=6
indicator("Smart Flow — SMC", overlay=true,
     max_boxes_count=500, max_lines_count=500, max_labels_count=500)

// ════════════════════════════════════════════════════════════════════════════
//  SETTINGS
// ════════════════════════════════════════════════════════════════════════════
swingLen     = input.int   (10,       "Swing Length (bars)",    minval=3, maxval=50,          group="⚙️  General")
obMitigation = input.string("Close",  "OB Mitigated by",        options=["Close","Wick"],     group="⚙️  General")

showBOS      = input.bool(true,  "Show BOS labels",             group="📊  Market Structure")
showCHoCH    = input.bool(true,  "Show CHoCH labels",           group="📊  Market Structure")
showOB       = input.bool(true,  "Show Order Blocks",           group="📦  Order Blocks")
showFVG      = input.bool(true,  "Show Fair Value Gaps",        group="📐  Fair Value Gaps")
showLiq      = input.bool(true,  "Show Liquidity Sweeps",       group="💧  Liquidity")
showArrows   = input.bool(true,  "Show Buy / Sell signals",     group="🎯  Signals")
showTrend    = input.bool(true,  "Color bars by trend",         group="🎯  Signals")
showSwingHL  = input.bool(true,  "Show Swing High/Low lines",   group="🎯  Signals")

// ─── Colors ──────────────────────────────────────────────────────────────────
bosColor     = input.color(color.new(#29b6f6, 0),   "BOS line",     group="🎨  Colors")
chochColor   = input.color(color.new(#ff7043, 0),   "CHoCH line",   group="🎨  Colors")
bullOBColor  = input.color(color.new(#26a69a, 75),  "Bullish OB",   group="🎨  Colors")
bearOBColor  = input.color(color.new(#ef5350, 75),  "Bearish OB",   group="🎨  Colors")
bullFVGColor = input.color(color.new(#4dd0e1, 85),  "Bullish FVG",  group="🎨  Colors")
bearFVGColor = input.color(color.new(#ffa726, 85),  "Bearish FVG",  group="🎨  Colors")
liqColor     = input.color(color.new(#ffd600, 0),   "Liq Sweep",    group="🎨  Colors")
buyColor     = input.color(color.new(#00c853, 0),   "Buy Signal",   group="🎨  Colors")
sellColor    = input.color(color.new(#d50000, 0),   "Sell Signal",  group="🎨  Colors")

// ════════════════════════════════════════════════════════════════════════════
//  PIVOT DETECTION
// ════════════════════════════════════════════════════════════════════════════
ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow (low,  swingLen, swingLen)

var float lastPH    = na
var int   lastPHBar = na
var float lastPL    = na
var int   lastPLBar = na

if not na(ph)
    lastPH    := ph
    lastPHBar := bar_index - swingLen

if not na(pl)
    lastPL    := pl
    lastPLBar := bar_index - swingLen

// ════════════════════════════════════════════════════════════════════════════
//  MARKET STRUCTURE — BOS & CHoCH
// ════════════════════════════════════════════════════════════════════════════
// trend: 0 = neutral, 1 = bullish, -1 = bearish
var int trend = 0

breakHigh = not na(lastPH) and ta.crossover(close, lastPH)
breakLow  = not na(lastPL) and ta.crossunder(close, lastPL)

// Evaluate structure BEFORE updating trend
isCHoCH_up   = breakHigh and trend == -1   // reversal to bull
isBOS_up     = breakHigh and trend ==  1   // bull continuation
isCHoCH_down = breakLow  and trend ==  1   // reversal to bear
isBOS_down   = breakLow  and trend == -1   // bear continuation
// First break from neutral (trend == 0) flips trend silently, no label

// Update trend
if breakHigh
    trend := 1
if breakLow
    trend := -1

// ─── BOS lines & labels ───────────────────────────────────────────────────
if showBOS
    if isBOS_up
        line.new (lastPHBar, lastPH, bar_index, lastPH, color=bosColor, style=line.style_dashed, width=1)
        label.new(bar_index, lastPH, "BOS ↑", color=color.new(bosColor, 80), textcolor=bosColor, style=label.style_label_down, size=size.tiny)
    if isBOS_down
        line.new (lastPLBar, lastPL, bar_index, lastPL, color=bosColor, style=line.style_dashed, width=1)
        label.new(bar_index, lastPL, "BOS ↓", color=color.new(bosColor, 80), textcolor=bosColor, style=label.style_label_up,   size=size.tiny)

// ─── CHoCH lines & labels ─────────────────────────────────────────────────
if showCHoCH
    if isCHoCH_up
        line.new (lastPHBar, lastPH, bar_index, lastPH, color=chochColor, style=line.style_dashed, width=2)
        label.new(bar_index, lastPH, "CHoCH ↑", color=color.new(chochColor, 80), textcolor=chochColor, style=label.style_label_down, size=size.tiny)
    if isCHoCH_down
        line.new (lastPLBar, lastPL, bar_index, lastPL, color=chochColor, style=line.style_dashed, width=2)
        label.new(bar_index, lastPL, "CHoCH ↓", color=color.new(chochColor, 80), textcolor=chochColor, style=label.style_label_up,   size=size.tiny)

// ════════════════════════════════════════════════════════════════════════════
//  BAR TREND COLOR  (barcolor must be at global scope)
// ════════════════════════════════════════════════════════════════════════════
barcolor(showTrend ? (trend == 1 ? color.new(color.green, 72) : trend == -1 ? color.new(color.red, 72) : na) : na)

// ════════════════════════════════════════════════════════════════════════════
//  ORDER BLOCKS
// ════════════════════════════════════════════════════════════════════════════
// Bullish OB = last bearish candle (close < open) before a bullish structure break
// Bearish OB = last bullish candle (close > open) before a bearish structure break

var box[] bullOBs = array.new<box>()
var box[] bearOBs = array.new<box>()

if showOB
    if isBOS_up or isCHoCH_up
        obIdx = 1
        for i = 1 to math.min(swingLen * 2, 50)
            if close[i] < open[i]  // find last bearish candle
                obIdx := i
                break
        b = box.new(bar_index - obIdx, high[obIdx], bar_index + 30, low[obIdx],
             bgcolor=bullOBColor,
             border_color=color.new(#26a69a, 20), border_width=1)
        array.push(bullOBs, b)

    if isBOS_down or isCHoCH_down
        obIdx = 1
        for i = 1 to math.min(swingLen * 2, 50)
            if close[i] > open[i]  // find last bullish candle
                obIdx := i
                break
        b = box.new(bar_index - obIdx, high[obIdx], bar_index + 30, low[obIdx],
             bgcolor=bearOBColor,
             border_color=color.new(#ef5350, 20), border_width=1)
        array.push(bearOBs, b)

// Extend or delete bull OBs
if showOB and array.size(bullOBs) > 0
    for i = array.size(bullOBs) - 1 to 0
        b   = array.get(bullOBs, i)
        bot = box.get_bottom(b)
        mitigated = obMitigation == "Close" ? close < bot : low < bot
        if mitigated
            box.delete(b)
            array.remove(bullOBs, i)
        else
            box.set_right(b, bar_index + 30)

// Extend or delete bear OBs
if showOB and array.size(bearOBs) > 0
    for i = array.size(bearOBs) - 1 to 0
        b   = array.get(bearOBs, i)
        top = box.get_top(b)
        mitigated = obMitigation == "Close" ? close > top : high > top
        if mitigated
            box.delete(b)
            array.remove(bearOBs, i)
        else
            box.set_right(b, bar_index + 30)

// ════════════════════════════════════════════════════════════════════════════
//  FAIR VALUE GAPS
// ════════════════════════════════════════════════════════════════════════════
// Bullish FVG : high[2] < low[0]  — gap up between bar[-2] top and bar[0] bottom
//   box top    = low[0]  | box bottom = high[2]
//   Mitigated when price retraces INTO the gap: low <= box_top (low[0])
//
// Bearish FVG : low[2] > high[0]  — gap down between bar[-2] bottom and bar[0] top
//   box top    = low[2]  | box bottom = high[0]
//   Mitigated when price rallies INTO the gap: high >= box_bottom (high[0])

var box[] bullFVGs = array.new<box>()
var box[] bearFVGs = array.new<box>()

if showFVG
    if high[2] < low[0]
        b = box.new(bar_index - 2, low[0], bar_index + 30, high[2],
             bgcolor=bullFVGColor, border_color=color.new(#4dd0e1, 30), border_width=1)
        array.push(bullFVGs, b)
    if low[2] > high[0]
        b = box.new(bar_index - 2, low[2], bar_index + 30, high[0],
             bgcolor=bearFVGColor, border_color=color.new(#ffa726, 30), border_width=1)
        array.push(bearFVGs, b)

// Mitigate bull FVGs (price enters from above)
if showFVG and array.size(bullFVGs) > 0
    for i = array.size(bullFVGs) - 1 to 0
        b   = array.get(bullFVGs, i)
        top = box.get_top(b)
        if low <= top
            box.delete(b)
            array.remove(bullFVGs, i)
        else
            box.set_right(b, bar_index + 30)

// Mitigate bear FVGs (price enters from below)
if showFVG and array.size(bearFVGs) > 0
    for i = array.size(bearFVGs) - 1 to 0
        b   = array.get(bearFVGs, i)
        bot = box.get_bottom(b)
        if high >= bot
            box.delete(b)
            array.remove(bearFVGs, i)
        else
            box.set_right(b, bar_index + 30)

// ════════════════════════════════════════════════════════════════════════════
//  LIQUIDITY SWEEPS
// ════════════════════════════════════════════════════════════════════════════
// Sweep of highs : wick above last swing high but CLOSES below it  → stop hunt on longs
// Sweep of lows  : wick below last swing low  but CLOSES above it  → stop hunt on shorts

sweepHigh = not na(lastPH) and high > lastPH and close < lastPH
sweepLow  = not na(lastPL) and low  < lastPL and close > lastPL

atr14 = ta.atr(14)

if showLiq
    if sweepHigh
        label.new(bar_index, high + atr14 * 0.15, "⚡ SWEEP",
             color=color.new(liqColor, 5), textcolor=color.black,
             style=label.style_label_down, size=size.tiny)
    if sweepLow
        label.new(bar_index, low - atr14 * 0.15, "⚡ SWEEP",
             color=color.new(liqColor, 5), textcolor=color.black,
             style=label.style_label_up, size=size.tiny)

// ════════════════════════════════════════════════════════════════════════════
//  BUY / SELL SIGNALS
// ════════════════════════════════════════════════════════════════════════════
// Buy  triggered by:  CHoCH to the upside  OR  sweep of lows (stop hunt reversal)
//                     while structure is not bearish
// Sell triggered by:  CHoCH to the downside OR  sweep of highs (stop hunt reversal)
//                     while structure is not bullish

buySignal  = isCHoCH_up   or (sweepLow  and trend >= 0)
sellSignal = isCHoCH_down or (sweepHigh and trend <= 0)

if showArrows
    if buySignal
        label.new(bar_index, low - atr14 * 0.9, "▲  BUY",
             color=buyColor, textcolor=color.white,
             style=label.style_label_up, size=size.small)
    if sellSignal
        label.new(bar_index, high + atr14 * 0.9, "▼  SELL",
             color=sellColor, textcolor=color.white,
             style=label.style_label_down, size=size.small)

// ════════════════════════════════════════════════════════════════════════════
//  SWING HIGH / LOW TRACKING LINES
// ════════════════════════════════════════════════════════════════════════════
plot(showSwingHL ? lastPH : na, "Swing High", color=color.new(color.red,   45), style=plot.style_stepline, linewidth=1)
plot(showSwingHL ? lastPL : na, "Swing Low",  color=color.new(color.green, 45), style=plot.style_stepline, linewidth=1)

// ════════════════════════════════════════════════════════════════════════════
//  ALERTS
// ════════════════════════════════════════════════════════════════════════════
alertcondition(buySignal,              title="Buy Signal",    message="Smart Flow: BUY signal detected")
alertcondition(sellSignal,             title="Sell Signal",   message="Smart Flow: SELL signal detected")
alertcondition(isCHoCH_up,             title="CHoCH Up",      message="Smart Flow: Bullish Change of Character")
alertcondition(isCHoCH_down,           title="CHoCH Down",    message="Smart Flow: Bearish Change of Character")
alertcondition(sweepHigh,              title="Sweep High",    message="Smart Flow: Liquidity sweep of highs")
alertcondition(sweepLow,               title="Sweep Low",     message="Smart Flow: Liquidity sweep of lows")
alertcondition(isCHoCH_up or isCHoCH_down, title="Any CHoCH", message="Smart Flow: Change of Character detected")
````
