# Smart Money AOI Strategy by fisa

- url: https://www.tradingview.com/script/BEDHcEbp-Smart-Money-AOI-Strategy-by-fisa/
- type: strategy
- pine_id: PUB;61107c2eb85744bda7c4ee9a8b0306f0
- version: 1.0

## Description

This is a multi-session trading indicator designed to help traders clearly identify key market sessions and stay aware of high-impact events. It automatically highlights major trading sessions such as London, New York, and Asia, allowing you to quickly understand current market conditions at a glance.

The indicator also includes a real-time session label, so you always know which session is active without needing to check manually. In addition, a built-in news guide provides awareness of upcoming high-impact events, helping you avoid unexpected volatility and manage risk more effectively.

This tool is ideal for traders who focus on intraday strategies, session-based setups, and volatility-driven moves. It simplifies chart analysis by combining session tracking and fundamental awareness into one clean, easy-to-read display.

## Source Code

````pine
//@version=5
strategy("Smart Money AOI Strategy", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=10)

// === INPUTS ===
showHTF = input.bool(true, "Show Higher Timeframe AOI")
htf_tf = input.timeframe("60", "HTF (1H default)")
bosLen = input.int(10, "Structure Length")
fvgSensitivity = input.float(0.5, "FVG Sensitivity")

// === STRUCTURE (BOS & CHoCH) ===
hh = ta.highest(high, bosLen)
ll = ta.lowest(low, bosLen)

bullBOS = close > hh[1]
bearBOS = close < ll[1]

plotshape(bullBOS, title="Bull BOS", location=location.belowbar, color=color.green, style=shape.labelup, text="BOS ↑")
plotshape(bearBOS, title="Bear BOS", location=location.abovebar, color=color.red, style=shape.labeldown, text="BOS ↓")

// === SHIFT (CHoCH) ===
chochBull = bullBOS and close[1] < ll[2]
chochBear = bearBOS and close[1] > hh[2]

plotshape(chochBull, location=location.belowbar, color=color.lime, style=shape.triangleup, text="Shift")
plotshape(chochBear, location=location.abovebar, color=color.orange, style=shape.triangledown, text="Shift")

// === FAIR VALUE GAP (FVG) ===
bullFVG = low > high[2]
bearFVG = high < low[2]

if bullFVG
    box.new(bar_index[2], high[2], bar_index, low, bgcolor=color.new(color.green, 85))
if bearFVG
    box.new(bar_index[2], high, bar_index, low[2], bgcolor=color.new(color.red, 85))

// === SUPPLY / DEMAND ===
demand = low == ta.lowest(low, bosLen)
supply = high == ta.highest(high, bosLen)

plotshape(demand, location=location.belowbar, color=color.green, style=shape.circle, size=size.tiny, title="Buyers")
plotshape(supply, location=location.abovebar, color=color.red, style=shape.circle, size=size.tiny, title="Sellers")

// === EQUAL HIGHS / LOWS (Liquidity) ===
eqHigh = math.abs(high - high[1]) < syminfo.mintick * 5
eqLow = math.abs(low - low[1]) < syminfo.mintick * 5

plotshape(eqHigh, location=location.abovebar, color=color.yellow, style=shape.xcross, size=size.tiny, title="Equal High")
plotshape(eqLow, location=location.belowbar, color=color.yellow, style=shape.xcross, size=size.tiny, title="Equal Low")

// === HTF AREA OF INTEREST ===
htfHigh = request.security(syminfo.tickerid, htf_tf, high)
htfLow = request.security(syminfo.tickerid, htf_tf, low)

if showHTF
    box.new(bar_index-10, htfHigh, bar_index, htfLow, bgcolor=color.new(color.blue, 90))

// === ENTRY LOGIC ===
// Conditions: BOS + Retest + FVG alignment
longCond = bullBOS and close > htfLow and bullFVG
shortCond = bearBOS and close < htfHigh and bearFVG

if longCond
    strategy.entry("BUY", strategy.long)
    label.new(bar_index, low, "BUY", style=label.style_label_up, color=color.green)

if shortCond
    strategy.entry("SELL", strategy.short)
    label.new(bar_index, high, "SELL", style=label.style_label_down, color=color.red)
    // === SESSION DETECTION ===
sessionAsia = (hour >= 0 and hour < 8)
sessionLondon = (hour >= 8 and hour < 13)
sessionNY = (hour >= 13 and hour < 17)

var label sessionLabel = na

if barstate.islast
    label.delete(sessionLabel)
    sessionText = sessionAsia ? "ASIA" : sessionLondon ? "LONDON" : sessionNY ? "NEW YORK" : "OFF SESSION"
    sessionColor = sessionAsia ? color.blue : sessionLondon ? color.orange : sessionNY ? color.green : color.gray
    sessionLabel := label.new(bar_index, low, sessionText, style=label.style_label_left, color=sessionColor, textcolor=color.white)

// === KILL ZONES (High Probability Times) ===
londonKill = (hour == 8)
nyKill = (hour == 13)

bgcolor(londonKill ? color.new(color.orange, 85) : na)
bgcolor(nyKill ? color.new(color.green, 85) : na)

// === MANUAL NEWS MARKER ===
newsHour = input.int(14, "News Hour (Manual)")
newsMinute = input.int(30, "News Minute")

isNewsTime = (hour == newsHour and minute == newsMinute)

if isNewsTime
    line.new(bar_index, high, bar_index, low, color=color.red, width=2)
    label.new(bar_index, high, "NEWS", color=color.red, style=label.style_label_down)
````
