# CHT 3 Consecutive Candles

- url: https://www.tradingview.com/script/hYIGyM0D-CHT-3-Consecutive-Candles/
- type: indicator
- pine_id: PUB;fac225f5dc7549b98ab0fb6e421ef9a5
- version: 3.0

## Description

This indicator spots when a set number of bullish or bearish candles form in a row, and marks it directly on your chart with a coloured box and a label.

How it works
A candle counts as bullish if it closes above its open, and bearish if it closes below its open. When the chosen number of same-direction candles appear back to back (3 by default), the indicator draws a box around the whole run. Green means a bullish run and red means a bearish run. A label at the edge of the box shows the candle count and direction (3▲ or 3▼). A doji, where the open and close are equal, counts as neither and breaks the run.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © chilton1

//@version=6
indicator("3 Consecutive Candles", shorttitle="3 Candles", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)

// ===== Signal =====
tfInput   = input.timeframe("", "Signal timeframe (blank = chart timeframe)", group="Signal")
n         = input.int(3, "Number of consecutive candles", minval=2, maxval=10, group="Signal")
firstOnly = input.bool(true, "Signal only on the first bar the pattern completes", group="Signal")
showLabel = input.bool(true, "Show label", group="Signal")
hpOnly    = input.bool(false, "High-probability only: each candle must break the previous candle's high (buys) / low (sells)", group="Signal")
hpMode    = input.string("Close beyond previous high/low", "Break type", options=["Close beyond previous high/low", "Wick beyond previous high/low"], group="Signal")
hpClose   = hpMode == "Close beyond previous high/low"

// ===== Box =====
showBox      = input.bool(true, "Draw a box around the candles", group="Box")
showOutline  = input.bool(true, "Show outline", group="Box")
showFill     = input.bool(true, "Show fill", group="Box")
outlineWidth = input.int(2, "Outline width", minval=1, maxval=5, group="Box")
outlineStyle = input.string("Solid", "Outline style", options=["Solid", "Dashed", "Dotted"], group="Box")
bullOutline  = input.color(color.green, "Bullish outline colour", group="Box")
bearOutline  = input.color(color.red, "Bearish outline colour", group="Box")
bullFill     = input.color(color.new(color.green, 85), "Bullish fill colour", group="Box")
bearFill     = input.color(color.new(color.red, 85), "Bearish fill colour", group="Box")

// ===== Take profit / stop loss =====
showTPSL      = input.bool(true, "Show TP / SL", group="TP / SL")
showTP        = input.bool(true, "Show TP", group="TP / SL")
showSL        = input.bool(true, "Show SL", group="TP / SL")
showMitigated = input.bool(true, "Show mitigated TP / SL", group="TP / SL")
showText      = input.bool(false, "Show TP / SL price text", group="TP / SL")
rr            = input.float(1.0, "Risk : reward (1 = 1:1)", minval=0.1, step=0.25, group="TP / SL")
extendBars    = input.int(20, "Extend zones to the right (bars)", minval=1, maxval=100, group="TP / SL")
tpFill        = input.color(color.new(color.green, 80), "TP zone colour", group="TP / SL")
slFill        = input.color(color.new(color.red, 80), "SL zone colour", group="TP / SL")
entryColor    = input.color(color.gray, "Entry line colour", group="TP / SL")

tf = tfInput == "" ? timeframe.period : tfInput

if timeframe.in_seconds(tf) < timeframe.in_seconds(timeframe.period)
    runtime.error("Signal timeframe must be equal to or higher than the chart timeframe.")

borderStyle = outlineStyle == "Dashed" ? line.style_dashed : outlineStyle == "Dotted" ? line.style_dotted : line.style_solid

// --- A TP/SL setup that is still being tracked ---
type Setup
    bool isBull
    float tp
    float sl
    int startBar
    int endBar
    box tpBox
    box slBox
    line tpLine
    line slLine
    line entryLine

var array<Setup> setups = array.new<Setup>()

// --- Pattern detection (runs on the selected timeframe) ---
f() =>
    isBull  = close > open
    isBear  = close < open
    brkBull = hpClose ? close > high[1] : high > high[1]
    brkBear = hpClose ? close < low[1] : low < low[1]
    bullRun = math.sum(isBull ? 1 : 0, n) == n and (not hpOnly or math.sum(brkBull ? 1 : 0, n - 1) == n - 1)
    bearRun = math.sum(isBear ? 1 : 0, n) == n and (not hpOnly or math.sum(brkBear ? 1 : 0, n - 1) == n - 1)
    bullSig = firstOnly ? (bullRun and not bullRun[1]) : bullRun
    bearSig = firstOnly ? (bearRun and not bearRun[1]) : bearRun
    [bullSig, bearSig, ta.highest(high, n), ta.lowest(low, n), time[n - 1], time_close, low[n - 1], high[n - 1], high, low]

[bullSig, bearSig, hi, lo, startT, endT, firstLow, firstHigh, lastHigh, lastLow] = request.security(syminfo.tickerid, tf, f(), lookahead = barmerge.lookahead_off)

// Only act on the chart bar that closes the higher-timeframe candle (no repainting)
closed  = barstate.isconfirmed and time_close == endT
bullNow = bullSig and closed
bearNow = bearSig and closed

// --- Create TP / SL zones ---
drawTPSL(bool isBull, float entry, float sl) =>
    valid = isBull ? sl < entry : sl > entry
    if valid
        tp = entry + (entry - sl) * rr
        x1 = bar_index
        x2 = bar_index + extendBars
        box tpBox = na
        box slBox = na
        line tpLine = na
        line slLine = na
        if showTP
            tpBox := box.new(x1, math.max(entry, tp), x2, math.min(entry, tp), border_color=na, bgcolor=tpFill,
                 text=showText ? "TP  " + str.tostring(tp, format.mintick) : "", text_color=color.white, text_size=size.small, text_halign=text.align_right)
            tpLine := line.new(x1, tp, x2, tp, color=color.new(tpFill, 0), width=1)
        if showSL
            slBox := box.new(x1, math.max(entry, sl), x2, math.min(entry, sl), border_color=na, bgcolor=slFill,
                 text=showText ? "SL  " + str.tostring(sl, format.mintick) : "", text_color=color.white, text_size=size.small, text_halign=text.align_right)
            slLine := line.new(x1, sl, x2, sl, color=color.new(slFill, 0), width=1)
        entryLine = line.new(x1, entry, x2, entry, color=entryColor, style=line.style_dashed, width=1)
        array.push(setups, Setup.new(isBull, tp, sl, x1, x2, tpBox, slBox, tpLine, slLine, entryLine))

// --- Check for mitigation (price touching the TP or SL) ---
if barstate.isconfirmed and array.size(setups) > 0
    for i = array.size(setups) - 1 to 0
        s = array.get(setups, i)
        hitTP = s.isBull ? high >= s.tp : low <= s.tp
        hitSL = s.isBull ? low <= s.sl : high >= s.sl
        if hitTP or hitSL
            if showMitigated
                // keep it, but stop the zone where price touched it
                if not na(s.tpBox)
                    box.set_right(s.tpBox, bar_index)
                if not na(s.slBox)
                    box.set_right(s.slBox, bar_index)
                if not na(s.tpLine)
                    line.set_x2(s.tpLine, bar_index)
                if not na(s.slLine)
                    line.set_x2(s.slLine, bar_index)
                line.set_x2(s.entryLine, bar_index)
            else
                // hide it
                box.delete(s.tpBox)
                box.delete(s.slBox)
                line.delete(s.tpLine)
                line.delete(s.slLine)
                line.delete(s.entryLine)
            array.remove(setups, i)
        else if bar_index >= s.endBar
            array.remove(setups, i)

// --- Drawing ---
if bullNow
    if showBox
        box.new(startT, hi, time, lo, xloc=xloc.bar_time,
             border_color=showOutline ? bullOutline : color.new(bullOutline, 100),
             border_width=outlineWidth, border_style=borderStyle,
             bgcolor=showFill ? bullFill : color.new(bullFill, 100))
    if showLabel
        label.new(time, lo, str.tostring(n) + "▲", xloc=xloc.bar_time, style=label.style_label_up, color=bullOutline, textcolor=color.white, size=size.small)
    if showTPSL
        drawTPSL(true, lastHigh, lo)

if bearNow
    if showBox
        box.new(startT, hi, time, lo, xloc=xloc.bar_time,
             border_color=showOutline ? bearOutline : color.new(bearOutline, 100),
             border_width=outlineWidth, border_style=borderStyle,
             bgcolor=showFill ? bearFill : color.new(bearFill, 100))
    if showLabel
        label.new(time, hi, str.tostring(n) + "▼", xloc=xloc.bar_time, style=label.style_label_down, color=bearOutline, textcolor=color.white, size=size.small)
    if showTPSL
        drawTPSL(false, lastLow, hi)

// --- Alerts ---
alertcondition(bullNow, title="Bullish run", message="{{ticker}}: consecutive bullish candles formed")
alertcondition(bearNow, title="Bearish run", message="{{ticker}}: consecutive bearish candles formed")
````
